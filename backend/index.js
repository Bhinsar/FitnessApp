const express = require("express");
const dotenv = require("dotenv");
const cookieParser = require("cookie-parser");
const bodyParser = require("body-parser");
const fs = require("fs");
const path = require("path");
const { readdirSync } = require("fs");
dotenv.config();

// Connect to MongoDB
require("./src/utils/connection");

const app = express();

const port = process.env.PORT || 8080;

app.use(bodyParser.json());
app.use(cookieParser());

readdirSync("./src/routes").map((r) => app.use("/", require("./src/routes/" + r)));

app.get("/", (req, res) => {
  res.send("Server is running");
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
