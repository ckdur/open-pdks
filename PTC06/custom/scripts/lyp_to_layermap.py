import xml.etree.ElementTree as ET
import sys

def lyp_to_layermap(lyp_filename):
    tree = ET.parse(lyp_filename)
    root = tree.getroot()
    
    layermap_lines = [
        "# Layer Map generated from KLayout .lyp file",
        "# LAYER_NAME   TYPE    GDS_NUM DATA_TYPE",
        "#" + "-"*40
    ]
    
    # Process each <properties> block in the XML
    for prop in root.findall("properties"):
        name_elem = prop.find("name")
        source_elem = prop.find("source")
        
        if name_elem is None or source_elem is None:
            continue
            
        full_name = name_elem.text if name_elem.text else ""
        source_str = source_elem.text if source_elem.text else ""
        
        # Skip entries without valid source GDS layer mapping (expects "layer/datatype")
        if "/" not in source_str:
            continue
            
        gds_num, gds_type = source_str.split("/")
        
        layer_name = full_name
        layer_type = "drawing"
            
        layermap_lines.append(f"{layer_name:<12} {layer_type:<8} {gds_num:<8} {gds_type}")

    # Write output layermap text file
    print("\n".join(layermap_lines) + "\n")

if __name__ == "__main__":
    lyp_file = sys.argv[1] if len(sys.argv) > 1 else "OpenRule1um/tech/tech/OpenRule1um.lyp"
    lyp_to_layermap(lyp_file)