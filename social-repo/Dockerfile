FROM node:19

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .
ENV DATABASE_URL 'postgres://postgres@postgres:5432/socialnetwork'

EXPOSE 3000

CMD ["npm","start"]