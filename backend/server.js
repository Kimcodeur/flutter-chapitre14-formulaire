const express = require("express");
const mongoose = require("mongoose");
const app = express();
const path = require("path");
const City = require("./models/city.model");
const Trip = require("./models/trip.model");

mongoose.set("debug", true);
mongoose
  .connect(
    "mongodb+srv://jean:123@cluster0-urpjt.gcp.mongodb.net/dymatrip?retryWrites=true&w=majority",
    {
      useNewUrlParser: true
    }
  )
  .then(() => console.log("connexion ok !"));

app.use(express.static(path.join(__dirname, "public")));
app.use(express.json());

// get cities
app.get("/api/cities", async (req, res) => {
  try {
    const cities = await City.find({}).exec();
    res.json(cities);
  } catch (e) {
    res.status(500).json(e);
  }
});

// get trips
app.get("/api/trips", async (req, res) => {
  try {
    const trips = await Trip.find({}).exec();
    res.json(trips);
  } catch (e) {
    res.status(500).json(e);
  }
});

// create trip
app.post("/api/trip", async (req, res) => {
  try {
    const body = req.body;
    const trip = await new Trip(body).save();
    res.json(trip);
  } catch (e) {
    res.status(500).json(e);
  }
});

// update trip
app.put("/api/trip", async (req, res) => {
  try {
    const body = req.body;
    const trip = await Trip.findOneAndUpdate({ _id: body._id }, body, {
      new: true
    }).exec();
    res.json(trip);
  } catch (e) {
    res.status(500).json(e);
  }
});

// add activity to a city
app.post("/api/city/:cityId/activity", async (req, res) => {
  try {
    const cityId = req.params.cityId;
    const activity = req.body;
    const city = await City.findOneAndUpdate(
      { _id: cityId },
      { $push: { activities: activity } },
      {
        new: true
      }
    ).exec();
    res.json(city);
  } catch (e) {
    res.status(500).json(e);
  }
});

// $host/api/city/${city.id}/activities/verify/$activityName
// verify uniqueness of a trip
app.get(
  "/api/city/:cityId/activities/verify/:activityName",
  async (req, res) => {
    const { cityId, activityName } = req.params;
    const city = await City.findById(cityId).exec();
    const index = city.activities.findIndex(
      activity => activity.name === activityName
    );
    index == -1 ? res.json() : res.json("L’activité existe déjà");
  }
);

app.listen(80);
