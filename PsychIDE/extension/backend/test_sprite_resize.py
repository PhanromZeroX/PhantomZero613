import json
import os
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image

BACKEND_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BACKEND_DIR))

from sprite_resizer import resize_sprite_sheet
from psych_lsp import PsychLanguageServer


class TestSpriteResize(unittest.TestCase):
    def test_resize_sprite_sheet_updates_image_and_metadata(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            image_path = tmp / 'sheet.png'
            xml_path = tmp / 'sheet.xml'
            json_path = tmp / 'sheet.json'

            Image.new('RGBA', (200, 100), (255, 0, 0, 255)).save(image_path)

            root = ET.Element('TextureAtlas', imagePath='sheet.png')
            sub = ET.SubElement(root, 'SubTexture', {'x': '10', 'y': '20', 'width': '40', 'height': '50'})
            ET.ElementTree(root).write(xml_path, encoding='utf-8', xml_declaration=True)

            json_data = {'frame': {'x': 10, 'y': 20, 'width': 40, 'height': 50}, 'scale': 1}
            json_path.write_text(json.dumps(json_data), encoding='utf-8')

            result = resize_sprite_sheet(
                str(image_path),
                target_width=100,
                xml_path=str(xml_path),
                json_paths=[str(json_path)],
                overwrite=True,
            )

            self.assertTrue(result['ok'])
            self.assertEqual(result['new_size'], [100, 50])
            self.assertTrue(os.path.exists(image_path))

            xml_tree = ET.parse(xml_path)
            xml_root = xml_tree.getroot()
            self.assertEqual(xml_root.attrib['imagePath'], 'sheet.png')
            self.assertEqual(xml_root.find('SubTexture').attrib['width'], '20')

            updated_json = json.loads(json_path.read_text(encoding='utf-8'))
            self.assertEqual(updated_json['frame']['width'], 20)
            self.assertEqual(updated_json['frame']['height'], 25)

    def test_language_server_resize_spritesheet_request(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            image_path = tmp / 'sprite.png'
            Image.new('RGBA', (400, 200), (0, 255, 0, 255)).save(image_path)

            server = PsychLanguageServer()
            result = server.resize_sprite_sheet({
                'imagePath': str(image_path),
                'targetWidth': 200,
                'overwrite': True,
            })

            self.assertTrue(result['ok'])
            self.assertEqual(result['new_size'], [200, 100])

    def test_named_export_preserves_source_and_updates_exported_metadata(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            source_image = tmp / 'hero.png'
            source_xml = tmp / 'hero.xml'
            output_image = tmp / 'standard' / 'hero_standard.png'
            output_xml = tmp / 'standard' / 'hero_standard.xml'
            Image.new('RGBA', (400, 200), (0, 0, 255, 255)).save(source_image)

            root = ET.Element('TextureAtlas', imagePath='hero.png')
            ET.SubElement(root, 'SubTexture', {'width': '100', 'height': '50'})
            ET.ElementTree(root).write(source_xml, encoding='utf-8', xml_declaration=True)

            result = resize_sprite_sheet(
                str(source_image),
                target_width=200,
                xml_path=str(source_xml),
                output_image_path=str(output_image),
                output_xml_path=str(output_xml),
            )

            self.assertTrue(result['ok'])
            with Image.open(source_image) as source:
                self.assertEqual(source.size, (400, 200))
            with Image.open(output_image) as exported:
                self.assertEqual(exported.size, (200, 100))
            exported_root = ET.parse(output_xml).getroot()
            self.assertEqual(exported_root.attrib['imagePath'], 'hero_standard.png')
            self.assertEqual(exported_root.find('SubTexture').attrib['width'], '50')


if __name__ == '__main__':
    unittest.main()
