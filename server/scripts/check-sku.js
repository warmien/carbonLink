const db = require('better-sqlite3')('C:/Users/warminen/DevEcoStudioProjects/CarbonLink/server/data/carbonlink.db');
const r = db.prepare("SELECT sql FROM sqlite_master WHERE type='table' AND name='spu'").get();
console.log(r.sql);
db.close();
