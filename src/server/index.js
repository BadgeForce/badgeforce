const path = require("path");
const session = require("cookie-session");
const express = require("express");
const bodyParser = require("body-parser");

const app = express();
const router = express.Router();

app.locals.name = "global-account-registration-yodlelive";

// Global middleware belongs in this file
app.use(session({ name: app.locals.name, keys: [">88X8+6nT4$Jsn?Y@7!6*j($o00X5RTpKZZS&Iv#6XuzG6/pV9ca?jjzDWpfY~,3"] }));
app.use(bodyParser.json());

const viewsPath = path.resolve(__dirname, "..", "..", "public");
app.set("views", viewsPath);
app.set("view engine", "ejs");

router.use("/gary/assets", express.static("./public/assets"));
router.use("/assets", express.static("./public/assets"));

// -------- API Routes -----------

router.get("/*", (req, res) => {
    res.render("index", { routeContext: "/gary/" });
});

app.use(router);

const port = process.env.SERVICE_PORT || 8080;
app.listen(port, function() {
    console.log(`${ app.locals.name } running on port ${ port }...`);
});
