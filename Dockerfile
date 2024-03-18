# Verwenden Sie ein offizielles Node.js-Runtime-Image als Basis
FROM node:18-alpine

# Setzen Sie das Arbeitsverzeichnis in Ihrem Docker-Image
WORKDIR /app

# Kopieren Sie die package.json und package-lock.json (wenn vorhanden) in das Arbeitsverzeichnis
COPY package*.json ./

# Installieren Sie die Abhängigkeiten Ihrer Anwendung
RUN npm install

# Kopieren Sie den Rest Ihrer Anwendung in das Arbeitsverzeichnis
COPY . .

# Bauen Sie Ihre Next.js-Anwendung
RUN npm run build

# Setzen Sie die Umgebungsvariable für den Produktionsmodus
ENV NODE_ENV production

# Öffnen Sie Port 3000
EXPOSE 3000

# Führen Sie Ihre Anwendung aus, wenn der Container gestartet wird
CMD ["npm", "start"]