const express = require('express');
const pg = require('pg');

const pool = new pg.Pool({
  host: process.env.HOST,
  port: process.env.PORT,
  database: process.env.DB,
  user: process.env.DBUSER,
  password: process.env.PASSWORD,
});

// pool.query('SELECT 1 + 1;').then(res => console.log(res));

const app = express();
app.use(express.urlencoded({ extended: true }));

app.get('/posts', async (req, res) => {
  const { rows } = await pool.query(`
    SELECT * FROM posts;
  `);

  res.send(`
    <table>
      <thead>
        <tr>
          <th>id</th>
          <th>lng</th>
          <th>lat</th>
        </tr>
      </thead>
      <tbody>
        ${rows
          .map(row => {
            return `
            <tr>
              <td>${row.id}</td>
              <td>${row.lng}</td>
              <td>${row.lat}</td>
            </tr>
          `;
          })
          .join('')}
      </tbody>
    </table>
    <form method="POST">
      <h3>Create Post</h3>
      <div>
        <label>Lng</label>
        <input name="lng" />
      </div>
      <div>
        <label>Lat</label>
        <input name="lat" />
      </div>
      <button type="submit">Create</button>
    </form>
  `);
});

app.post('/posts', async (req, res) => {
  const { lng, lat } = req.body;
  console.log('send query');
  const results = await pool.query(
    'INSERT INTO posts (lat, lng, loc) VALUES ($1, $2, $3);',
    [lat, lng, `(${lng},${lat})`]
  );
  console.log(results);
  console.log('success');
  res.redirect('/posts');
});

app.listen(3005, () => {
  console.log('Listening on port 3005');
});
