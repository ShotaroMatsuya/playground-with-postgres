const pg = require('pg');

const pool = new pg.Pool({
  host: process.env.HOST,
  port: process.env.PORT,
  database: process.env.DB,
  user: process.env.DBUSER,
  password: process.env.PASSWORD,
});

pool
  .query(
    `
    UPDATE posts
    SET loc = POINT(lng, lat)
    WHERE loc IS NULL;
`
  )
  .then(() => {
    console.log('Update Complete');
    pool.end();
  })
  .catch(err => console.error(err.message));
