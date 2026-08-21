"""
Haxe source parser - extracts Psych Engine API specifications
from Haxe source files for autocompletion and validation.
"""

import re
from typing import Dict, List, Any
from pathlib import Path


class HaxeParser:
    def __init__(self, haxe_source_dir: str):
        self.haxe_source_dir = Path(haxe_source_dir)
        self.functions = {}
        self.classes = {}
        
    def parse_file(self, filepath: Path) -> Dict[str, Any]:
        """Parse a Haxe file and extract function/class signatures"""
        try:
            content = filepath.read_text(encoding='utf-8')
        except:
            return {}
        
        specs = {
            'functions': [],
            'classes': [],
            'fields': [],
            'imports': [],
            'file': str(filepath)
        }

        package_match = re.search(r'\bpackage\s+([\w.]+)\s*;', content)
        package_name = package_match.group(1) if package_match else ''
        specs['package'] = package_name
        specs['imports'] = re.findall(r'\bimport\s+([\w.]+)\s*;', content)
        
        # Extract public functions
        func_pattern = r'(?:(public|private|protected)\s+)?(?:(static|override|inline)\s+)*function\s+(\w+)\s*\((.*?)\)\s*(?::\s*([\w<>.?]+))?'
        for match in re.finditer(func_pattern, content):
            visibility, modifier, func_name, params, return_type = match.groups()
            specs['functions'].append({
                'name': func_name,
                'params': self._parse_params(params),
                'return_type': return_type or 'Void',
                'visibility': visibility or 'private',
                'modifier': modifier or '',
                'package': package_name,
                'file': filepath.resolve().as_uri(),
            })
        
        # Extract classes
        class_pattern = r'(?:class|extern\s+class)\s+(\w+)'
        for match in re.finditer(class_pattern, content):
            class_name = match.group(1)
            specs['classes'].append({'name': class_name, 'package': package_name, 'file': filepath.resolve().as_uri()})

        field_pattern = r'(?:(public|private|protected)\s+)?(?:static\s+)?(?:var|final)\s+(\w+)\s*:\s*([\w<>.?]+)'
        for match in re.finditer(field_pattern, content):
            specs['fields'].append({
                'name': match.group(2),
                'type': match.group(3),
                'visibility': match.group(1) or 'private',
                'package': package_name,
                'file': filepath.resolve().as_uri(),
            })
        
        return specs
    
    def _parse_params(self, params_str: str) -> List[Dict[str, str]]:
        """Parse function parameters"""
        params = []
        if not params_str.strip():
            return params
        
        for param in params_str.split(','):
            param = param.strip()
            match = re.match(r'(?:(\w+)\s*:\s*)?(\w+(?:<[^>]+>)?(?:\?)?)', param)
            if match:
                params.append({'name': match.group(1) or 'arg', 'type': match.group(2)})
        return params
    
    def extract_all_apis(self) -> Dict[str, List[Dict]]:
        """Scan all Haxe files and extract API specs"""
        apis = {'functions': [], 'classes': [], 'fields': [], 'imports': []}
        
        ignored = {'.git', '.buildozer', 'node_modules', 'out', 'build', 'dist', '__pycache__'}
        for haxe_file in self.haxe_source_dir.glob('**/*.hx'):
            if ignored.intersection(haxe_file.parts):
                continue
            specs = self.parse_file(haxe_file)
            apis['functions'].extend(specs.get('functions', []))
            apis['classes'].extend(specs.get('classes', []))
            apis['fields'].extend(specs.get('fields', []))
            apis['imports'].extend({item for item in specs.get('imports', []) if item})

        apis['imports'] = sorted(apis['imports'])
        
        return apis
