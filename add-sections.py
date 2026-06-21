#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script pour ajouter les sections new-section dans ansible.md
"""

def insert_section(content, pattern, route_alias, title):
    """Insert a new-section slide before the pattern"""
    section = f"""---
layout: new-section
routeAlias: '{route_alias}'
---

<a name="{route_alias}" id="{route_alias}"></a>

# {title}

---

"""
    # Find the pattern and insert the section before it
    if pattern in content:
        content = content.replace(pattern, section + pattern)
        print(f"✅ Ajouté: {title}")
    else:
        print(f"⚠️  Pattern non trouvé: {pattern[:50]}...")
    
    return content

def main():
    # Read the file
    with open('pages/ansible.md', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Define the sections to add
    sections = [
        # Module 3 : CI/CD (avec apostrophe typographique)
        ("# Intégration d'Ansible dans un workflow CI/CD", 'ci-cd-integration', 'Module 3 : Intégration CI/CD'),
        
        # Module 4 : Inventaires
        ("# Qu'est-ce qu'un Inventaire ? 📋", 'inventaires', 'Module 4 : Inventaires et serveurs'),
        
        # Module 5 : Playbooks
        ("# Qu'est-ce qu'un Playbook ? 🎭", 'playbooks', 'Module 5 : Playbooks'),
        
        # Module 6 : Modules
        ("# Qu'est-ce qu'un Module ? 📦", 'modules', 'Module 6 : Modules essentiels'),
        
        # Module 7 : Variables
        ("# Qu'est-ce qu'une Variable ? 🔧", 'variables', 'Module 7 : Variables'),
        
        # Module 8 : Templates
        ("# Qu'est-ce qu'un Template ? 📄", 'templates', 'Module 8 : Templates Jinja2'),
        
        # Module 9 : Handlers
        ("# Qu'est-ce qu'un Handler ? 🎯", 'handlers', 'Module 9 : Handlers'),
        
        # Module 10 : Rôles
        ("# Qu'est-ce qu'un Rôle ? 📦", 'roles', 'Module 10 : Rôles'),
        
        # Module 11 : Stack complète
        ("# Ansible + Docker : Stack complète 🐳", 'stack-complete', 'Module 11 : Stack Ansible + Docker'),
        
        # Module 12 : Collections
        ("# Qu'est-ce qu'une Collection ? 🌐", 'collections', 'Module 12 : Collections'),
        
        # Module 13 : Vault
        ("# Qu'est-ce qu'Ansible Vault ? 🔐", 'vault', 'Module 13 : Ansible Vault'),
        
        # Module 14 : Bonnes pratiques
        ("# Optimisation et bonnes pratiques 🚀", 'bonnes-pratiques', 'Module 14 : Optimisation & Bonnes pratiques'),
        
        # Module 15 : Tags
        ("# Qu'est-ce qu'un Tag ? 🏷️", 'tags', 'Module 15 : Tags et exécution sélective'),
    ]
    
    # Insert all sections
    for pattern, route_alias, title in sections:
        content = insert_section(content, pattern, route_alias, title)
    
    # Write the modified content
    with open('pages/ansible.md', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("\n✅ Toutes les sections ont été ajoutées avec succès !")

if __name__ == '__main__':
    main()
