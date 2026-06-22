process.on('uncaughtException', (err) => {
  console.error('UNCAUGHT:', err.message, err.stack);
});
process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION:', err);
});
require('ts-node').register({transpileOnly:true});
console.log('[start] Loading index.ts...');
require('./src/index.ts');
console.log('[start] index.ts loaded');
