from pathlib import Path
root=Path(__file__).resolve().parents[1]
xml=(root/'Project.xml').read_text(encoding='utf-8')
assert 'file="MonsterMatch" main="Main"' in xml
xml=xml.replace('file="MonsterMatch" main="Main"','file="MonsterArcadeRegression" main="MonsterArcadeTestMain"',1)
assert '<classpath name="source" />' in xml
xml=xml.replace('<classpath name="source" />','<classpath name="source" /><classpath name="tests/arcade" />',1)
xml=xml.replace('name="BUILD_DIR" value="export"','name="BUILD_DIR" value="export/arcade-tests"')
(root/'ArcadeTest.xml').write_text(xml,encoding='utf-8')
