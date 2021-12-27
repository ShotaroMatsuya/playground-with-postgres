const pool = require('../pool');
const toCamelCase = require('./utils/to-camel-case');
// module.exports = {
//     find(){},
//     findById(){},
//     insert(){};
// };

class UserRepo {
  static async find() {
    const { rows } = await pool.query('SELECT * FROM users;');
    return toCamelCase(rows);
  }
  static async findById(id) {
    // warning : really big security issue
    const { rows } = await pool.query(`
      SELECT * FROM users WHERE id = ${id};
    `);
    return toCamelCase(rows)[0];
  }
  static async insert() {}
  static async update() {}
  static async delete() {}
}

module.exports = UserRepo;
