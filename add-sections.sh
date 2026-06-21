#!/bin/bash

# Script pour ajouter les sections new-section dans ansible.md

FILE="pages/ansible.md"
TEMP="pages/ansible.md.tmp"

cp "$FILE" "$TEMP"

# Function to insert section before a pattern
insert_section_before() {
    local route_alias=$1
    local title=$2
    local pattern=$3
    local section="---\nlayout: new-section\nrouteAlias: '$route_alias'\n---\n\n<a name=\"$route_alias\" id=\"$route_alias\"></a>\n\n# $title\n\n---\n\n"
    
    sed -i.bak "/$pattern/i\\
$section" "$TEMP"
}

# Remplacer le début (déjà fait)
# Module 1 : Introduction - déjà fait manuellement

# Module 4 : Inventaires
sed -i.bak '/^# Qu'\''est-ce qu'\''un Inventaire ? 📋/i\
---\
layout: new-section\
routeAlias: '"'"'inventaires'"'"'\
---\
\
<a name="inventaires" id="inventaires"></a>\
\
# Module 4 : Inventaires et serveurs\
\
---\
' "$TEMP"

# Module 5 : Playbooks
sed -i.bak '/^# Qu'\''est-ce qu'\''un Playbook ? 🎭/i\
---\
layout: new-section\
routeAlias: '"'"'playbooks'"'"'\
---\
\
<a name="playbooks" id="playbooks"></a>\
\
# Module 5 : Playbooks\
\
---\
' "$TEMP"

# Module 6 : Modules
sed -i.bak '/^# Qu'\''est-ce qu'\''un Module ? 📦/i\
---\
layout: new-section\
routeAlias: '"'"'modules'"'"'\
---\
\
<a name="modules" id="modules"></a>\
\
# Module 6 : Modules essentiels\
\
---\
' "$TEMP"

# Module 7 : Variables
sed -i.bak '/^# Qu'\''est-ce qu'\''une Variable ? 🔧/i\
---\
layout: new-section\
routeAlias: '"'"'variables'"'"'\
---\
\
<a name="variables" id="variables"></a>\
\
# Module 7 : Variables\
\
---\
' "$TEMP"

# Module 8 : Templates
sed -i.bak '/^# Qu'\''est-ce qu'\''un Template ? 📄/i\
---\
layout: new-section\
routeAlias: '"'"'templates'"'"'\
---\
\
<a name="templates" id="templates"></a>\
\
# Module 8 : Templates Jinja2\
\
---\
' "$TEMP"

# Module 9 : Handlers
sed -i.bak '/^# Qu'\''est-ce qu'\''un Handler ? 🎯/i\
---\
layout: new-section\
routeAlias: '"'"'handlers'"'"'\
---\
\
<a name="handlers" id="handlers"></a>\
\
# Module 9 : Handlers\
\
---\
' "$TEMP"

# Module 10 : Rôles
sed -i.bak '/^# Qu'\''est-ce qu'\''un Rôle ? 📦/i\
---\
layout: new-section\
routeAlias: '"'"'roles'"'"'\
---\
\
<a name="roles" id="roles"></a>\
\
# Module 10 : Rôles\
\
---\
' "$TEMP"

# Module 11 : Stack complète
sed -i.bak '/^# Ansible + Docker : Stack complète 🐳/i\
---\
layout: new-section\
routeAlias: '"'"'stack-complete'"'"'\
---\
\
<a name="stack-complete" id="stack-complete"></a>\
\
# Module 11 : Stack Ansible + Docker\
\
---\
' "$TEMP"

# Module 12 : Collections
sed -i.bak '/^# Qu'\''est-ce qu'\''une Collection ? 🌐/i\
---\
layout: new-section\
routeAlias: '"'"'collections'"'"'\
---\
\
<a name="collections" id="collections"></a>\
\
# Module 12 : Collections\
\
---\
' "$TEMP"

# Module 13 : Vault
sed -i.bak '/^# Qu'\''est-ce qu'\''Ansible Vault ? 🔐/i\
---\
layout: new-section\
routeAlias: '"'"'vault'"'"'\
---\
\
<a name="vault" id="vault"></a>\
\
# Module 13 : Ansible Vault\
\
---\
' "$TEMP"

# Module 14 : Bonnes pratiques
sed -i.bak '/^# Optimisation et bonnes pratiques 🚀/i\
---\
layout: new-section\
routeAlias: '"'"'bonnes-pratiques'"'"'\
---\
\
<a name="bonnes-pratiques" id="bonnes-pratiques"></a>\
\
# Module 14 : Optimisation & Bonnes pratiques\
\
---\
' "$TEMP"

# Module 15 : Tags
sed -i.bak '/^# Qu'\''est-ce qu'\''un Tag ? 🏷️/i\
---\
layout: new-section\
routeAlias: '"'"'tags'"'"'\
---\
\
<a name="tags" id="tags"></a>\
\
# Module 15 : Tags et exécution sélective\
\
---\
' "$TEMP"

# Remplacer le fichier original
mv "$TEMP" "$FILE"

# Nettoyer les backups
rm -f pages/ansible.md.tmp.bak

echo "✅ Sections ajoutées avec succès !"
