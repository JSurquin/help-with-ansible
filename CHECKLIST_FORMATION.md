# ✅ Checklist de vérification - Formation Ansible 2026

## 🎯 Vérification rapide avant la formation

### Module 7 - Variables ✅

**Nouvelles slides ajoutées** :
- [ ] Slide "Variables : Précédence détaillée" (5 niveaux)
- [ ] Slide "Variables : Précédence détaillée (suite)" (exemple nginx_port)
- [ ] Slide "Règle d'or : defaults/ vs vars/" (partie 1)
- [ ] Slide "Règle d'or : defaults/ vs vars/ (suite)" (partie 2)
- [ ] Slide "Exemple concret de précédence" (webapp)
- [ ] Slide "Exemple concret de précédence (suite 2)" (role vars)
- [ ] Slide "Tableau récapitulatif complet" (18 niveaux)

**Points clés à expliquer** :
- ✅ extra-vars > playbook vars > **role vars** > group_vars > defaults
- ✅ defaults/ = configuration personnalisable
- ✅ vars/ = constantes système
- ✅ Pourquoi role vars est plus fort que group_vars

---

### Module 9 - Handlers ✅

**Nouvelles slides ajoutées** :
- [ ] Slide "Troubleshooting : Handlers" (4 raisons)
- [ ] Slide "Raison 1 : Nom différent" (casse/espaces)
- [ ] Slide "Raison 2 : changed: false" (idempotence)
- [ ] Slide "Raison 3 : Playbook échoué" (handlers à la fin)
- [ ] Slide "Raison 3 : Playbook échoué (suite)" (--force-handlers)
- [ ] Slide "Raison 4 : Mode check" (pas d'exécution)
- [ ] Slide "Test de handlers en pratique" (exercice)
- [ ] Slide "Test de handlers en pratique (suite)" (diagnostic)
- [ ] Slide "Test de handlers en pratique (suite 2)" (causes)
- [ ] Slide "Bonnes pratiques handlers 2026" (5 points)

**Points clés à expliquer** :
- ✅ notify = nom EXACT du handler (casse, espaces)
- ✅ Handler se déclenche SEULEMENT si changed: true
- ✅ Handlers s'exécutent à la FIN du playbook
- ✅ --force-handlers pour forcer en cas d'erreur
- ✅ 2 exécutions = test d'idempotence

---

### Module 10 - Rôles ✅

**Nouvelles slides ajoutées** :
- [ ] Slide "defaults/ vs vars/ : La différence cruciale"
- [ ] Slide "defaults/main.yml : Configuration"
- [ ] Slide "defaults/main.yml : Configuration (suite)"
- [ ] Slide "vars/main.yml : Constantes"
- [ ] Slide "vars/main.yml : Constantes (suite)"
- [ ] Slide "Exemple réel : Rôle Apache2"
- [ ] Slide "Exemple réel : Rôle Apache2 (suite)"
- [ ] Slide "Test pratique : defaults vs vars"
- [ ] Slide "Test pratique : defaults vs vars (suite)"
- [ ] Slide "Tableau récapitulatif defaults vs vars"
- [ ] Slide "Bonnes pratiques 2026 : Variables de rôles"

**Points clés à expliquer** :
- ✅ defaults/ = priorité FAIBLE (facilement surchargeable)
- ✅ vars/ = priorité FORTE (difficilement surchargeable)
- ✅ Ports, timeouts → defaults/
- ✅ Chemins, packages → vars/
- ✅ Si hésitation → mettre dans defaults/

---

## 🧪 Tests à effectuer avant la formation

### Test 1 : Idempotence des handlers

```bash
cd correction

# 1ère exécution - handlers doivent se déclencher
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml -v | grep "RUNNING HANDLER"
# Attendu : ✅ RUNNING HANDLER [restart nginx]

# 2ème exécution - handlers NE doivent PAS se déclencher
ansible-playbook -i inventories/nginx.yml playbooks/play-nginx.yml -v | grep "RUNNING HANDLER"
# Attendu : ❌ Aucune sortie (pas de handler)
```

### Test 2 : Précédence des variables

```bash
# Créer un playbook de test
cat > test-precedence.yml << 'EOF'
---
- hosts: localhost
  vars:
    test_var: "playbook"
  tasks:
    - debug:
        msg: "test_var = {{ test_var }}"
EOF

# Test 1 : Sans extra-vars
ansible-playbook test-precedence.yml
# Attendu : test_var = playbook

# Test 2 : Avec extra-vars
ansible-playbook test-precedence.yml -e "test_var=extra"
# Attendu : test_var = extra (surcharge ✅)
```

### Test 3 : defaults vs vars dans rôle

```bash
# Dans correction/roles/nginx/
# Vérifier que vars/main.yml contient des constantes
grep -E "package|service|path" roles/nginx/vars/main.yml
# Attendu : nginx_package, nginx_service, nginx_config_path...

# Vérifier que defaults/main.yml existe (même si vide pour l'instant)
ls roles/nginx/defaults/main.yml 2>/dev/null || echo "À créer si config personnalisable"
```

---

## 📋 Points d'attention pendant la formation

### Module 7 - Variables

**Quand présenter** :
1. Montrer d'abord l'ordre simplifié (slide originale)
2. Dire "En réalité, c'est plus complexe..."
3. Montrer les 7 nouvelles slides
4. Insister sur **role vars > group_vars** (souvent oublié)

**Démo live recommandée** :
```bash
# Montrer la surcharge avec extra-vars
ansible-playbook play.yml -e "var=override" -v
```

**Questions attendues** :
- Q: "Pourquoi role vars est plus fort que group_vars ?"
- R: "Pour protéger les constantes système du rôle"

---

### Module 9 - Handlers

**Quand présenter** :
1. Montrer d'abord comment créer un handler (slides originales)
2. Dire "Maintenant, les pièges courants..."
3. Montrer les 10 nouvelles slides de troubleshooting
4. **DÉMO LIVE OBLIGATOIRE** : 2 exécutions pour l'idempotence

**Démo live recommandée** :
```bash
# 1ère exécution
ansible-playbook play.yml -v
# Montrer : RUNNING HANDLER

# 2ème exécution
ansible-playbook play.yml -v
# Montrer : PAS de RUNNING HANDLER (c'est normal!)

# Expliquer : "Si rien ne change, pourquoi redémarrer ?"
```

**Questions attendues** :
- Q: "Mon handler ne se déclenche jamais !"
- R: "Checklist : 1) Nom identique ? 2) Changed: true ? 3) Playbook terminé ?"

---

### Module 10 - Rôles

**Quand présenter** :
1. Montrer d'abord la structure de rôle (slides originales)
2. Arriver à defaults/ et vars/
3. Dire "Quelle différence entre les deux ?"
4. Montrer les 11 nouvelles slides
5. Insister sur le choix defaults/ vs vars/

**Démo live recommandée** :
```bash
# Montrer un rôle existant
tree roles/nginx/
cat roles/nginx/vars/main.yml
# Expliquer chaque variable
```

**Questions attendues** :
- Q: "Je mets tout dans defaults/ ou tout dans vars/ ?"
- R: "Si l'utilisateur doit pouvoir changer → defaults/, sinon → vars/"

---

## 🎓 Conseils pédagogiques

### Ordre de présentation optimal

**Jour 1** :
- Modules 1-6 : Bases
- **Module 7 (Variables)** : Bien prendre le temps (30 min)
  - Ordre simplifié d'abord
  - Précédence détaillée ensuite
  - Exemples concrets

**Jour 2** :
- Module 8 : Templates
- **Module 9 (Handlers)** : Avec démo live obligatoire (45 min)
  - Création d'abord
  - Troubleshooting ensuite
  - Test d'idempotence en live
- **Module 10 (Rôles)** : defaults/ vs vars/ (1h)
  - Structure d'abord
  - différence defaults/vars ensuite
  - Exercice pratique

### Timing ajusté

**Module 7 (Variables)** :
- Avant : 15 min
- Après : 30 min (+7 slides)

**Module 9 (Handlers)** :
- Avant : 20 min
- Après : 45 min (+10 slides + démo)

**Module 10 (Rôles)** :
- Avant : 30 min
- Après : 60 min (+11 slides)

**Total ajouté** : ~1h de contenu supplémentaire

---

## 📊 Évaluation post-formation

### Questions à ajouter au QCM

**Variables** :
```
Q: Quelle est la priorité la plus forte après extra-vars ?
A) role vars
B) group_vars
C) defaults
Réponse : A (task vars/role params, mais role vars pour les rôles)

Q: Où mettre une variable de port configurable ?
A) roles/*/defaults/main.yml
B) roles/*/vars/main.yml
Réponse : A
```

**Handlers** :
```
Q: Un handler se déclenche si :
A) La tâche s'exécute
B) La tâche retourne changed: true
C) On le met dans handlers/
Réponse : B

Q: Comment forcer les handlers en cas d'erreur ?
A) --force-handlers
B) --run-handlers
C) force: yes dans le handler
Réponse : A
```

---

## ✅ Validation finale

**Avant la formation** :
- [ ] Tester tous les playbooks de correction
- [ ] Vérifier l'idempotence (2 exécutions)
- [ ] Lancer docker-compose dans correction/
- [ ] Préparer les démos live
- [ ] Imprimer le tableau de précédence (slide)

**Pendant la formation** :
- [ ] Démo idempotence handlers (Module 9)
- [ ] Démo extra-vars (Module 7)
- [ ] Montrer tree roles/nginx/ (Module 10)

**Après la formation** :
- [ ] Collecter feedback sur nouvelles slides
- [ ] Vérifier si questions sur defaults/vars
- [ ] Noter les points à améliorer

---

## 🚀 Ressources additionnelles

**Liens utiles à partager** :
- https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html

**Dépôt de la formation** :
- https://github.com/JSurquin/ansible

---

## 📞 Support

Si problème technique pendant la formation :
1. Vérifier Docker : `docker ps`
2. Vérifier Ansible : `ansible --version`
3. Re-lancer correction : `cd correction && docker-compose restart`

**En cas de questions apprenants** :
- Variables : Référer à la slide "Tableau récapitulatif complet"
- Handlers : Référer à la slide "Troubleshooting : Handlers"
- Rôles : Référer à la slide "Tableau récapitulatif defaults vs vars"
