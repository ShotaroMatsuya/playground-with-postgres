FROM node:14

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .
ENV DATABASE_URL 'postgres://postgres@postgres:5432/socialnetwork'

EXPOSE 3005

CMD ["npm","start"]