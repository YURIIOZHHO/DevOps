import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import { createClient } from "redis";

const redisClient = createClient({
  url: "redis://redis:6379"
});

redisClient.on("error", (err) => console.error("Redis error", err));

await redisClient.connect();
console.log("Redis connected");

const app = express();

app.use(cors({
  origin: ["http://localhost", "http://frontend"]
}));

app.use(express.json());

mongoose.connect("mongodb://db:27017/forms_db")
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error(err));


const FormSchema = new mongoose.Schema({
  name: String,
  email: String,
  message: String,
}, { timestamps: true });

const Form = mongoose.model("Form", FormSchema);

app.post("/api/form", async (req, res) => {
  try {

    console.log(req.body)

    const form = new Form(req.body);
    await form.save();
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(5000, () => {
  console.log("Server running on http://localhost:5000");
});
