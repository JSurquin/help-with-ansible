# 1. Image de base optimisée
FROM node:20-alpine

# 4. Répertoire de travail
WORKDIR /app

RUN npm install -g vite 
RUN npm install -g pnpm

# /app => ./
# ./ => /app

# 5. Dépendances (ordre optimal pour le cache)

COPY package*.json pnpm-lock.yaml ./

# Je vais copier les fichiers de dépendances dans le containeur
# Litérallement : il va copier le package.json dans le dossier /app qu'on viens de créer
RUN pnpm install

# /app/node_modules

COPY . .

RUN pnpm run build

# Puis je vais exécuter la commande npm ci --only=production et npm cache clean --force
# Cette commande va installer les dépendances nécessaires pour le projet
# Puis je vais nettoyer le cache de npm pour économiser de l'espace

# 8. Configuration
EXPOSE 3000

# 9. Démarrage
CMD ["pnpm", "run", "start"]
