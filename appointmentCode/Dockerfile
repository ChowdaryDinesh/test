FROM node:12.18.1
WORKDIR /app
RUN npm install express
COPY app.js .
ARG port=3001
EXPOSE $port
CMD ["npm", "start"]