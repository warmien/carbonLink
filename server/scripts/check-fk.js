const db = require('better-sqlite3')('C:/Users/warminen/DevEcoStudioProjects/CarbonLink/server/data/carbonlink.db');
const info = db.prepare("PRAGMA foreign_key_list(orders)").all();
info.forEach(fk => console.log(`from: ${fk.from} -> table: ${fk.table} to: ${fk.to}`));
db.close();