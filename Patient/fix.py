import os

def fix_conflicts(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    in_conflict = False
    in_head = False
    in_incoming = False
    
    for line in lines:
        if line.startswith('<<<<<<< HEAD'):
            in_conflict = True
            in_head = True
            continue
        elif line.startswith('======='):
            in_head = False
            in_incoming = True
            continue
        elif line.startswith('>>>>>>>'):
            in_conflict = False
            in_incoming = False
            continue
            
        if not in_conflict:
            new_lines.append(line)
        elif in_incoming:
            new_lines.append(line)
            
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print(f"Fixed {filepath}")

def scan_dir(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    if '<<<<<<< HEAD' in content:
                        fix_conflicts(filepath)
                except Exception as e:
                    pass

scan_dir('d:\\medassestflutterapk\\_MedAssist-AI-repo\\Patient\\lib')
