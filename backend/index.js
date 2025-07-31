const express = require("express");
const dotenv = require("dotenv");
const cookieParser = require("cookie-parser");
const bodyParser = require("body-parser");
const path = require("path");
const { readdirSync } = require("fs");

dotenv.config();

require("./src/utils/connection");

const app = express();

app.use(bodyParser.json());
app.use(cookieParser());

const routesPath = path.join(__dirname, "src/routes");
readdirSync(routesPath).map((r) =>
  app.use("/", require(path.join(routesPath, r)))
);

app.get("/running", (req, res) => {
  res.send("Server is running");
});

module.exports = app;