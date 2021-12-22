FROM node:14

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .
ENV DATABASE_URL 'postgres://postgres@localhost:5432/postgres'

# EXPOSE 3000

# CMD ["npm","run","migrate","up"]