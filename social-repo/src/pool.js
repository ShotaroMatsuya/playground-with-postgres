const pg = require('pg');

// Normally, we would create a pool like this;
// const pool = new pg.Pool({
//   host: process.env.HOST,
//   port: process.env.PORT,
//   database: process.env.DB,
//   user: process.env.DBUSER,
//   password: process.env.PASSWORD,
// });

// module.exports = pool;

class Pool {
  _pool = null;
  connect(options) {
    this._pool = new pg.Pool(options);
    return this._pool.query('SELECT 1 + 1;');
  }
  close() {
    return this._pool.end();
  }
  // really big security issue here!
  query(sql) {
    return this._pool.query(sql);
  }
}

module.exports = new Pool();
