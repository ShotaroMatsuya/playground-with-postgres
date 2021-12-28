const { randomBytes } = require('crypto');
const format = require('pg-format');
const { default: migrate } = require('node-pg-migrate');
const pool = require('../pool');

const DEFAULT_OPTS = {
  host: process.env.HOST,
  port: process.env.PORT,
  database: process.env.TEST_DB,
  user: process.env.DBUSER,
  password: process.env.PASSWORD,
};
class Context {
  static async build() {
    // 1. Randomly generating a role name to connect to PG as
    const roleName = 'a' + randomBytes(4).toString('hex');
    // 2. Connect to PG as usual
    await pool.connect(DEFAULT_OPTS);
    // 3. Create a new role
    //   await pool.query(`
    //     CREATE ROLE ${roleName} WITH LOGIN PASSWORD '${$roleName}';
    //   `);
    await pool.query(
      format('CREATE ROLE %I WITH LOGIN PASSWORD %L;', roleName, roleName)
    );
    // 4. Create a schema with the same name
    //   await pool.query(`
    //     CREATE SCHEMA ${roleName} AUTHORIZATION ${$roleName};
    //   `);
    await pool.query(
      format('CREATE SCHEMA %I AUTHORIZATION %I;', roleName, roleName)
    );
    // 5. Disconnect entirely from PG
    await pool.close();

    // 6. Run our migrations in the new schema
    await migrate({
      schema: roleName,
      direction: 'up',
      log: () => {},
      noLock: true, // by default, be supposed to only be running one set of migration at a time
      dir: 'migrations', //where migrations files be
      databaseUrl: {
        host: process.env.HOST,
        port: process.env.PORT,
        database: process.env.TEST_DB,
        user: roleName,
        password: roleName,
      },
    });
    // 7. Connect to PG as the newly created role
    await pool.connect({
      host: process.env.HOST,
      port: process.env.PORT,
      database: process.env.TEST_DB,
      user: roleName,
      password: roleName,
    });
    return new Context(roleName);
  }
  constructor(roleName) {
    this.roleName = roleName;
  }
  async close() {
    // 1.Disconnect from PG
    await pool.close();
    // 2.Reconnect as our root user
    await pool.connect(DEFAULT_OPTS);
    // 3.Delete the role and schema we created
    await pool.query(format('DROP SCHEMA %I CASCADE;', this.roleName));
    await pool.query(format('DROP ROLE %I;', this.roleName));
    // 4.Disconnect
    await pool.close();
  }
}

module.exports = Context;
