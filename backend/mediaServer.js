import NodeMediaServer from "node-media-server";
import path from "path";
import fs from "fs";
import { spawn } from "child_process";

const mediaRoot = path.join(process.cwd(), "media");
const liveRoot = path.join(mediaRoot, "live");

// Track ffmpeg processes by stream key
const ffmpegProcesses = new Map();

if (!fs.existsSync(mediaRoot)) {
  fs.mkdirSync(mediaRoot, { recursive: true });
}

if (!fs.existsSync(liveRoot)) {
  fs.mkdirSync(liveRoot, { recursive: true });
}

const config = {
  logType: 3,

  rtmp: {
    port: 1935,
    host: "0.0.0.0",
    chunk_size: 60000,
    gop_cache: true,
    ping: 30,
    ping_timeout: 60,
  },

  http: {
    port: 8000,
    host: "0.0.0.0",
    mediaroot: mediaRoot,
    allow_origin: "*",
  },
};

const nms = new NodeMediaServer(config);

// Helper: delete folder recursively
function removeDirSafe(dirPath) {
  try {
    if (fs.existsSync(dirPath)) {
      fs.rmSync(dirPath, { recursive: true, force: true });
    }
  } catch (err) {
    console.error("REMOVE DIR ERROR:", err);
  }
}

// Helper: ensure folder exists
function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

// Start manual ffmpeg HLS process
function startFfmpegForStream(streamKey) {
  try {
    // If already running for same key, stop old one first
    if (ffmpegProcesses.has(streamKey)) {
      console.log(`⚠️ FFmpeg already running for ${streamKey}, restarting...`);
      stopFfmpegForStream(streamKey);
    }

    const streamDir = path.join(liveRoot, streamKey);

    // clean old HLS files
    removeDirSafe(streamDir);
    ensureDir(streamDir);

    const ffmpegPath = "/opt/homebrew/bin/ffmpeg"; // change if needed
    const inputUrl = `rtmp://127.0.0.1:1935/live/${streamKey}`;
    const outputPath = path.join(streamDir, "index.m3u8");

    console.log("🎬 Starting FFmpeg HLS pipeline:", {
      streamKey,
      inputUrl,
      outputPath,
    });

    const args = [
      "-y",
      "-i", inputUrl,

      // Video: copy for lower CPU (OBS already encodes)
      "-c:v", "copy",

      // Audio: AAC for HLS/browser compatibility
      "-c:a", "aac",
      "-b:a", "128k",
      "-ar", "44100",
      "-ac", "2",

      // HLS output
      "-f", "hls",
      "-hls_time", "2",
      "-hls_list_size", "5",
      "-hls_flags", "delete_segments+append_list",
      "-hls_segment_filename", path.join(streamDir, "segment_%03d.ts"),

      outputPath,
    ];

    const ffmpeg = spawn(ffmpegPath, args);

    ffmpeg.stdout.on("data", (data) => {
      console.log(`[FFmpeg ${streamKey} stdout]: ${data.toString()}`);
    });

    ffmpeg.stderr.on("data", (data) => {
      // ffmpeg logs mostly on stderr even for normal info
      console.log(`[FFmpeg ${streamKey}]: ${data.toString()}`);
    });

    ffmpeg.on("close", (code) => {
      console.log(`🛑 FFmpeg process closed for ${streamKey} with code ${code}`);
      ffmpegProcesses.delete(streamKey);
    });

    ffmpeg.on("error", (err) => {
      console.error(`❌ FFmpeg spawn error for ${streamKey}:`, err);
      ffmpegProcesses.delete(streamKey);
    });

    ffmpegProcesses.set(streamKey, ffmpeg);
  } catch (err) {
    console.error("START FFMPEG ERROR:", err);
  }
}

// Stop manual ffmpeg HLS process
function stopFfmpegForStream(streamKey) {
  try {
    const proc = ffmpegProcesses.get(streamKey);
    if (!proc) return;

    console.log(`🛑 Stopping FFmpeg for stream ${streamKey}`);
    proc.kill("SIGINT");
    ffmpegProcesses.delete(streamKey);
  } catch (err) {
    console.error("STOP FFMPEG ERROR:", err);
  }
}

// OBS connected (pre publish)
nms.on("prePublish", (...args) => {
  console.log("[NodeMediaServer] prePublish:", args);
});

// OBS started pushing stream
nms.on("postPublish", (...args) => {
  console.log("[NodeMediaServer] postPublish:", args);

  try {
    // Different versions pass different args
    // Safely extract stream path from known shapes
    let streamPath = null;

    for (const arg of args) {
      if (typeof arg === "string" && arg.startsWith("/live/")) {
        streamPath = arg;
        break;
      }

      if (arg && typeof arg === "object") {
        if (typeof arg.streamPath === "string" && arg.streamPath.startsWith("/live/")) {
          streamPath = arg.streamPath;
          break;
        }

        if (arg.rtmp && typeof arg.rtmp.streamName === "string") {
          streamPath = `/live/${arg.rtmp.streamName}`;
          break;
        }

        if (typeof arg.streamName === "string") {
          streamPath = `/live/${arg.streamName}`;
          break;
        }
      }
    }

    if (!streamPath) {
      console.warn("⚠️ Could not resolve streamPath in postPublish args");
      return;
    }

    const parts = streamPath.split("/");
    const streamKey = parts[2];

    if (!streamKey) {
      console.warn("⚠️ Could not resolve streamKey from streamPath:", streamPath);
      return;
    }

    console.log(`🚀 Stream published: ${streamPath}, streamKey=${streamKey}`);

    // Give NMS a tiny moment before ffmpeg attaches
    setTimeout(() => {
      startFfmpegForStream(streamKey);
    }, 1000);
  } catch (err) {
    console.error("POST PUBLISH HANDLER ERROR:", err);
  }
});

// OBS stopped streaming
nms.on("donePublish", (...args) => {
  console.log("[NodeMediaServer] donePublish:", args);

  try {
    let streamPath = null;

    for (const arg of args) {
      if (typeof arg === "string" && arg.startsWith("/live/")) {
        streamPath = arg;
        break;
      }

      if (arg && typeof arg === "object") {
        if (typeof arg.streamPath === "string" && arg.streamPath.startsWith("/live/")) {
          streamPath = arg.streamPath;
          break;
        }

        if (arg.rtmp && typeof arg.rtmp.streamName === "string") {
          streamPath = `/live/${arg.rtmp.streamName}`;
          break;
        }

        if (typeof arg.streamName === "string") {
          streamPath = `/live/${arg.streamName}`;
          break;
        }
      }
    }

    if (!streamPath) {
      console.warn("⚠️ Could not resolve streamPath in donePublish args");
      return;
    }

    const parts = streamPath.split("/");
    const streamKey = parts[2];

    if (!streamKey) return;

    console.log(`🛑 Stream ended: ${streamPath}, streamKey=${streamKey}`);
    stopFfmpegForStream(streamKey);
  } catch (err) {
    console.error("DONE PUBLISH HANDLER ERROR:", err);
  }
});

export function startMediaServer() {
  nms.run();

  console.log("🎥 Node Media Server started");
  console.log("RTMP: rtmp://127.0.0.1:1935/live (local test)");
  console.log("HLS:  http://127.0.0.1:8000/live/<streamKey>/index.m3u8");
}