FROM node:18

WORKDIR /app
COPY . .

ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL

RUN npm install
RUN npm run build
RUN npm install -g serve

EXPOSE 3000
CMD ["serve", "-s", "build"]
