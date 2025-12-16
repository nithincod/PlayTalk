const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("PlayTalk Backend Running");
});
const events=[];
app.post("/event", (req, res) => {
  const event = req.body;

  if (!event.event_type || !event.player) {
    return res.status(400).json({ error: "Invalid event data" });
  }
  events.push(event);
  console.log("Received Event:", event);

  res.json({
    status: "Event received",
    event_type: event.event_type
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
