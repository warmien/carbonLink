const Database = require('better-sqlite3');
const path = require('path');
const db = new Database(path.join(__dirname, '..', 'data', 'carbonlink.db'));

const insert = db.prepare('INSERT INTO carbon_credit_table (category, name, min_reduction, max_reduction, min_credits, max_credits) VALUES (?, ?, ?, ?, ?, ?)');

const data = [
  ['\u7535\u5b50\u6570\u7801', '\u65e7\u624b\u673a', 8, 15, 20, 40],
  ['\u7535\u5b50\u6570\u7801', '\u5e73\u677f\u7535\u8111', 10, 20, 25, 50],
  ['\u7535\u5b50\u6570\u7801', '\u84dd\u7259\u8033\u673a', 2, 5, 5, 15],
  ['\u7535\u5b50\u6570\u7801', '\u667a\u80fd\u624b\u8868', 3, 8, 8, 20],
  ['\u7535\u5b50\u6570\u7801', '\u7b14\u8bb0\u672c\u7535\u8111', 20, 40, 50, 100],
  ['\u7535\u5b50\u6570\u7801', '\u5145\u7535\u5668\u6570\u636e\u7ebf', 0.5, 1.5, 2, 5],
  ['\u7535\u5b50\u6570\u7801', '\u76f8\u673a\u6444\u5f71', 5, 12, 15, 30],
  ['\u7535\u5b50\u6570\u7801', '\u952e\u76d8\u9f20\u6807', 1, 3, 3, 10],
  ['\u7535\u5b50\u6570\u7801', '\u97f3\u7bb1\u8033\u673a', 2, 6, 5, 15],
  ['\u7535\u5b50\u6570\u7801', '\u6e38\u620f\u673a', 5, 15, 12, 35],
  ['\u7535\u5b50\u6570\u7801', '\u7535\u5b50\u9605\u8bfb\u5668', 3, 8, 8, 20],
  ['\u7535\u5b50\u6570\u7801', 'U\u76d8\u786c\u76d8', 1, 4, 3, 10],
  ['\u7535\u5b50\u6570\u7801', '\u5176\u4ed6\u7535\u5b50', 2, 8, 5, 20],
  ['\u56fe\u4e66\u6559\u6750', '\u4e66\u7c4d', 1, 3, 3, 8],
  ['\u56fe\u4e66\u6559\u6750', '\u7b14\u8bb0\u672c', 0.5, 1.5, 2, 5],
  ['\u56fe\u4e66\u6559\u6750', '\u8003\u7814\u7f51\u8bfe\u8d26\u53f7', 0.2, 1, 1, 3],
  ['\u670d\u88c5\u978b\u5e3d', '\u5916\u5957', 3, 8, 8, 20],
  ['\u670d\u88c5\u978b\u5e3d', '\u5305', 2, 5, 5, 15],
  ['\u670d\u88c5\u978b\u5e3d', '\u5e3d\u5b50', 0.5, 2, 2, 5],
  ['\u670d\u88c5\u978b\u5e3d', '\u889c\u5b50\u7c7b', 0.2, 1, 1, 3],
  ['\u670d\u88c5\u978b\u5e3d', '\u4e1d\u5dfe\u7c7b', 0.5, 2, 2, 5],
  ['\u670d\u88c5\u978b\u5e3d', '\u4e0a\u8863', 2, 6, 5, 15],
  ['\u670d\u88c5\u978b\u5e3d', '\u88e4\u88d9', 2, 5, 5, 12],
  ['\u670d\u88c5\u978b\u5e3d', '\u978b', 2, 6, 5, 15],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u5c0f\u7535\u716e\u9505', 3, 8, 8, 20],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u53f0\u706f', 1, 4, 3, 10],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u6563\u70ed\u67b6', 0.5, 2, 2, 5],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u6536\u7eb3\u67b6', 0.5, 2, 2, 5],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u5e8a\u4e0a\u7528\u54c1', 2, 5, 5, 12],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u88c5\u9970\u6446\u4ef6', 0.5, 2, 2, 5],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u5c0f\u5bb6\u7535', 3, 10, 8, 25],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u53a8\u5177\u9910\u5177', 1, 4, 3, 10],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u6e05\u6d01\u7528\u54c1', 0.5, 2, 2, 5],
  ['\u5bb6\u5c45\u751f\u6d3b', '\u5176\u4ed6\u5bb6\u5c45', 1, 5, 3, 12],
  ['\u7f8e\u5986\u62a4\u80a4', '\u7cbe\u534e', 0.5, 2, 2, 5],
  ['\u7f8e\u5986\u62a4\u80a4', '\u9762\u971c', 0.5, 2, 2, 5],
  ['\u7f8e\u5986\u62a4\u80a4', '\u53e3\u7ea2', 0.2, 1, 1, 3],
  ['\u7f8e\u5986\u62a4\u80a4', '\u773c\u5f71', 0.2, 1, 1, 3],
  ['\u7f8e\u5986\u62a4\u80a4', '\u9762\u819c', 0.2, 1, 1, 3],
  ['\u7f8e\u5986\u62a4\u80a4', '\u9999\u6c34', 0.5, 2, 2, 5],
  ['\u7f8e\u5986\u62a4\u80a4', '\u7f8e\u5986\u5de5\u5177', 0.2, 1, 1, 3],
  ['\u7f8e\u5986\u62a4\u80a4', '\u5176\u4ed6\u7f8e\u5986', 0.2, 1, 1, 3],
  ['\u8fd0\u52a8\u6237\u5916', '\u7403\u7c7b', 1, 3, 3, 8],
  ['\u8fd0\u52a8\u6237\u5916', '\u8f66\u7c7b', 5, 15, 12, 35],
  ['\u8fd0\u52a8\u6237\u5916', '\u5065\u8eab\u5361', 0.2, 1, 1, 3],
  ['\u8fd0\u52a8\u6237\u5916', '\u745c\u4f3d\u57ab', 0.5, 2, 2, 5],
  ['\u8fd0\u52a8\u6237\u5916', '\u8fd0\u52a8\u978b', 2, 5, 5, 12],
  ['\u8fd0\u52a8\u6237\u5916', '\u8fd0\u52a8\u670d', 1, 4, 3, 10],
  ['\u8fd0\u52a8\u6237\u5916', '\u6237\u5916\u88c5\u5907', 2, 6, 5, 15],
  ['\u8fd0\u52a8\u6237\u5916', '\u5176\u4ed6\u8fd0\u52a8', 1, 4, 3, 10],
  ['\u6587\u5177\u529e\u516c', '\u6587\u5177', 0.2, 1, 1, 3],
  ['\u6587\u5177\u529e\u516c', '\u8ba1\u7b97\u5668', 0.5, 2, 2, 5],
  ['\u6587\u5177\u529e\u516c', '\u80cc\u4e66\u6905', 2, 5, 5, 12],
  ['\u4e50\u5668\u6587\u521b', '\u4e8c\u624b\u4e50\u5668', 3, 10, 8, 25],
  ['\u4e50\u5668\u6587\u521b', '\u6587\u521b\u4ea7\u54c1', 0.5, 2, 2, 5],
  ['\u4e50\u5668\u6587\u521b', '\u7eff\u690d', 0.5, 2, 2, 5],
  ['\u865a\u62df\u670d\u52a1', '\u8003\u7814\u7f51\u8bfe\u8d26\u53f7', 0.2, 1, 1, 3],
  ['\u865a\u62df\u670d\u52a1', '\u5065\u8eab\u5361', 0.2, 1, 1, 3],
  ['\u865a\u62df\u670d\u52a1', '\u6c34\u5361', 0.1, 0.5, 1, 2],
  ['\u5176\u4ed6\u95f2\u7f6e', '\u5176\u4ed6\u95f2\u7f6e', 0.5, 5, 2, 12],
];

const tx = db.transaction(() => {
  let count = 0;
  for (const row of data) {
    insert.run(row[0], row[1], row[2], row[3], row[4], row[5]);
    count++;
  }
  return count;
});

const count = tx();
console.log('Inserted ' + count + ' rows into carbon_credit_table');

const verify = db.prepare('SELECT COUNT(*) as c FROM carbon_credit_table').get();
console.log('Total rows:', verify.c);

db.close();