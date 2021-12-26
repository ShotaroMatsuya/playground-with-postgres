const app = require('./src/app.js');
const pool = require('./src/pool.js');

pool
  .connect({
    host: process.env.HOST,
    port: process.env.PORT,
    database: process.env.DB,
    user: process.env.DBUSER,
    password: process.env.PASSWORD,
  })
  .then(() => {
    app().listen(3000, () => {
      console.log('Listening on port 3000');
    });
  })
  .catch(err => {
    console.error(err);
  });
