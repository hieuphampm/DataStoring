import xml.etree.ElementTree as ET

tree = ET.parse('students.xml')
root = tree.getroot()

print("DS SV:")
for student in root.findall("student"):
    code = student.attrib.get("code")
    name = student.find("full_name").text
    dob = student.find("dob").text
    gender = student.find('gender').text
    print(f"- {code}: {name} | {dob} | {gender}")