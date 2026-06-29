#!/usr/bin/env python3
"""Generate Chambea.xcodeproj with correct group hierarchy."""

import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT_NAME = "Chambea"
BUNDLE_ID = "com.chambea.app"

def uid(seed: str) -> str:
    return hashlib.md5(seed.encode()).hexdigest().upper()[:24]

IDS = {
    "project": "A10000000000000000000001",
    "main_target": "A10000000000000000000002",
    "test_target": "A10000000000000000000003",
    "ui_test_target": "A10000000000000000000004",
    "main_group": "A10000000000000000000005",
    "products_group": "A10000000000000000000006",
    "sources_phase": "A10000000000000000000007",
    "resources_phase": "A10000000000000000000008",
    "frameworks_phase": "A10000000000000000000009",
    "test_sources_phase": "A10000000000000000000010",
    "ui_test_sources_phase": "A10000000000000000000011",
    "proj_debug": "A10000000000000000000012",
    "main_debug": "A10000000000000000000013",
    "main_release": "A10000000000000000000014",
    "test_debug": "A10000000000000000000015",
    "test_release": "A10000000000000000000016",
    "ui_test_debug": "A10000000000000000000017",
    "ui_test_release": "A10000000000000000000018",
    "main_config_list": "A10000000000000000000019",
    "test_config_list": "A10000000000000000000020",
    "ui_test_config_list": "A10000000000000000000021",
    "proj_config_list": "A10000000000000000000022",
    "app_product": "A10000000000000000000023",
    "test_product": "A10000000000000000000024",
    "ui_test_product": "A10000000000000000000025",
    "proj_release": "A10000000000000000000026",
}

swift_files = sorted((ROOT / PROJECT_NAME).rglob("*.swift"))
test_files = sorted((ROOT / f"{PROJECT_NAME}Tests").rglob("*.swift"))
ui_test_files = sorted((ROOT / f"{PROJECT_NAME}UITests").rglob("*.swift"))
resource_files = [
    ROOT / PROJECT_NAME / "Resources" / "Assets.xcassets",
    ROOT / PROJECT_NAME / "Resources" / "Localizable.xcstrings",
]

file_refs: dict[str, tuple[str, Path]] = {}
build_files: dict[str, list[tuple[str, str, Path]]] = {
    IDS["sources_phase"]: [],
    IDS["test_sources_phase"]: [],
    IDS["ui_test_sources_phase"]: [],
    IDS["resources_phase"]: [],
}

def register_file(path: Path, phase: str):
    rel = str(path.relative_to(ROOT))
    ref_id = uid(f"ref:{rel}")
    build_id = uid(f"build:{rel}")
    file_refs[rel] = (ref_id, path)
    build_files[phase].append((build_id, ref_id, path))

for f in swift_files:
    register_file(f, IDS["sources_phase"])
for f in test_files:
    register_file(f, IDS["test_sources_phase"])
for f in ui_test_files:
    register_file(f, IDS["ui_test_sources_phase"])
for f in resource_files:
    register_file(f, IDS["resources_phase"])

# Build directory tree
class DirNode:
    def __init__(self, name: str, rel: str):
        self.name = name
        self.rel = rel
        self.subdirs: dict[str, "DirNode"] = {}
        self.files: list[str] = []  # ref ids

root_nodes = {
    PROJECT_NAME: DirNode(PROJECT_NAME, PROJECT_NAME),
    f"{PROJECT_NAME}Tests": DirNode(f"{PROJECT_NAME}Tests", f"{PROJECT_NAME}Tests"),
    f"{PROJECT_NAME}UITests": DirNode(f"{PROJECT_NAME}UITests", f"{PROJECT_NAME}UITests"),
}

for rel, (ref_id, path) in file_refs.items():
    parts = Path(rel).parts
    top = parts[0]
    node = root_nodes[top]
    if len(parts) == 2:
        node.files.append(ref_id)
    else:
        current = node
        for part in parts[1:-1]:
            current = current.subdirs.setdefault(part, DirNode(part, f"{current.rel}/{part}"))
        current.files.append(ref_id)

group_ids: dict[str, str] = {}

def group_id_for(rel: str) -> str:
    if rel not in group_ids:
        group_ids[rel] = uid(f"group:{rel}")
    return group_ids[rel]

def render_group(node: DirNode) -> list[str]:
    gid = group_id_for(node.rel)
    children = [group_id_for(sd.rel) for sd in sorted(node.subdirs.values(), key=lambda x: x.name)]
    children += sorted(node.files)
    lines = [f"\t\t{gid} /* {node.name} */ = {{"]
    lines.append("\t\t\tisa = PBXGroup;")
    lines.append("\t\t\tchildren = (")
    for c in children:
        label = next((Path(k).name for k, (rid, _) in file_refs.items() if rid == c), None)
        if not label:
            for sd in node.subdirs.values():
                if group_id_for(sd.rel) == c:
                    label = sd.name
                    break
        lines.append(f"\t\t\t\t{c} /* {label} */,")
    lines.append("\t\t\t);")
    if node.rel in root_nodes:
        lines.append(f"\t\t\tpath = {node.name};")
    else:
        lines.append(f"\t\t\tpath = {node.name};")
    lines.append("\t\t\tsourceTree = \"<group>\";")
    lines.append("\t\t};")
    result = lines
    for sd in sorted(node.subdirs.values(), key=lambda x: x.name):
        result += render_group(sd)
    return result

lines = ["// !$*UTF8*$!", "{", "\tarchiveVersion = 1;", "\tclasses = {", "};", "\tobjectVersion = 56;", "\tobjects = {"]

lines.append("\n/* Begin PBXBuildFile section */")
for phase, items in build_files.items():
    for build_id, ref_id, path in items:
        section = "Sources" if path.suffix == ".swift" else "Resources"
        lines.append(f"\t\t{build_id} /* {path.name} in {section} */ = {{isa = PBXBuildFile; fileRef = {ref_id} /* {path.name} */; }};")
lines.append("/* End PBXBuildFile section */")

lines.append("\n/* Begin PBXFileReference section */")
lines.append(f"\t\t{IDS['app_product']} /* {PROJECT_NAME}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {PROJECT_NAME}.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
lines.append(f"\t\t{IDS['test_product']} /* {PROJECT_NAME}Tests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {PROJECT_NAME}Tests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};")
lines.append(f"\t\t{IDS['ui_test_product']} /* {PROJECT_NAME}UITests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = {PROJECT_NAME}UITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};")
for rel, (ref_id, path) in file_refs.items():
    if path.suffix == ".swift":
        lines.append(f"\t\t{ref_id} /* {path.name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {path.name}; sourceTree = \"<group>\"; }};")
    elif path.suffix == ".xcstrings":
        lines.append(f"\t\t{ref_id} /* {path.name} */ = {{isa = PBXFileReference; lastKnownFileType = text.json.xcstrings; path = {path.name}; sourceTree = \"<group>\"; }};")
    else:
        lines.append(f"\t\t{ref_id} /* {path.name} */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = {path.name}; sourceTree = \"<group>\"; }};")
lines.append("/* End PBXFileReference section */")

lines.append("\n/* Begin PBXFrameworksBuildPhase section */")
for key, label in [("frameworks_phase", "Chambea"), ("test_fw", "Tests"), ("ui_test_fw", "UITests")]:
    phase = IDS.get(key) or uid(key)
    if key != "frameworks_phase":
        IDS[key] = phase
    lines += [
        f"\t\t{phase} /* Frameworks */ = {{",
        "\t\t\tisa = PBXFrameworksBuildPhase;",
        "\t\t\tbuildActionMask = 2147483647;",
        "\t\t\trunOnlyForDeploymentPostprocessing = 0;",
        "\t\t\tfiles = (",
        "\t\t\t);",
        "\t\t};",
    ]
lines.append("/* End PBXFrameworksBuildPhase section */")

lines.append("\n/* Begin PBXGroup section */")
lines.append(f"\t\t{IDS['main_group']} = {{")
lines.append("\t\t\tisa = PBXGroup;")
lines.append("\t\t\tchildren = (")
lines.append(f"\t\t\t\t{group_id_for(PROJECT_NAME)} /* {PROJECT_NAME} */,")
lines.append(f"\t\t\t\t{group_id_for(f'{PROJECT_NAME}Tests')} /* {PROJECT_NAME}Tests */,")
lines.append(f"\t\t\t\t{group_id_for(f'{PROJECT_NAME}UITests')} /* {PROJECT_NAME}UITests */,")
lines.append(f"\t\t\t\t{IDS['products_group']} /* Products */,")
lines.append("\t\t\t);")
lines.append("\t\t\tsourceTree = \"<group>\";")
lines.append("\t\t};")
lines.append(f"\t\t{IDS['products_group']} /* Products */ = {{")
lines.append("\t\t\tisa = PBXGroup;")
lines.append("\t\t\tchildren = (")
lines.append(f"\t\t\t\t{IDS['app_product']} /* {PROJECT_NAME}.app */,")
lines.append(f"\t\t\t\t{IDS['test_product']} /* {PROJECT_NAME}Tests.xctest */,")
lines.append(f"\t\t\t\t{IDS['ui_test_product']} /* {PROJECT_NAME}UITests.xctest */,")
lines.append("\t\t\t);")
lines.append("\t\t\tname = Products;")
lines.append("\t\t\tsourceTree = \"<group>\";")
lines.append("\t\t};")
for top in [PROJECT_NAME, f"{PROJECT_NAME}Tests", f"{PROJECT_NAME}UITests"]:
    lines += render_group(root_nodes[top])
lines.append("/* End PBXGroup section */")

# Native targets, project, phases, dependencies, configs - abbreviated but valid
lines.append("\n/* Begin PBXNativeTarget section */")
lines.append(f"\t\t{IDS['main_target']} /* {PROJECT_NAME} */ = {{")
lines.append("\t\t\tisa = PBXNativeTarget;")
lines.append(f"\t\t\tbuildConfigurationList = {IDS['main_config_list']};")
lines.append("\t\t\tbuildPhases = (")
lines.append(f"\t\t\t\t{IDS['sources_phase']} /* Sources */,")
lines.append(f"\t\t\t\t{IDS['frameworks_phase']} /* Frameworks */,")
lines.append(f"\t\t\t\t{IDS['resources_phase']} /* Resources */,")
lines.append("\t\t\t);")
lines.append("\t\t\tbuildRules = ();")
lines.append("\t\t\tdependencies = ();")
lines.append(f"\t\t\tname = {PROJECT_NAME};")
lines.append(f"\t\t\tproductName = {PROJECT_NAME};")
lines.append(f"\t\t\tproductReference = {IDS['app_product']};")
lines.append("\t\t\tproductType = \"com.apple.product-type.application\";")
lines.append("\t\t};")

for tid, tname, src_phase, prod, clist, fw in [
    (IDS["test_target"], f"{PROJECT_NAME}Tests", IDS["test_sources_phase"], IDS["test_product"], IDS["test_config_list"], IDS["test_fw"]),
    (IDS["ui_test_target"], f"{PROJECT_NAME}UITests", IDS["ui_test_sources_phase"], IDS["ui_test_product"], IDS["ui_test_config_list"], IDS["ui_test_fw"]),
]:
    dep = uid(f"dep:{tname}")
    proxy = uid(f"proxy:{tname}")
    lines += [
        f"\t\t{tid} /* {tname} */ = {{",
        "\t\t\tisa = PBXNativeTarget;",
        f"\t\t\tbuildConfigurationList = {clist};",
        "\t\t\tbuildPhases = (",
        f"\t\t\t\t{src_phase} /* Sources */,",
        f"\t\t\t\t{fw} /* Frameworks */,",
        "\t\t\t);",
        "\t\t\tbuildRules = ();",
        "\t\t\tdependencies = (",
        f"\t\t\t\t{dep} /* PBXTargetDependency */,",
        "\t\t\t);",
        f"\t\t\tname = {tname};",
        f"\t\t\tproductName = {tname};",
        f"\t\t\tproductReference = {prod};",
        "\t\t\tproductType = \"com.apple.product-type.bundle.unit-test\";",
        "\t\t};",
        f"\t\t{dep} /* PBXTargetDependency */ = {{",
        "\t\t\tisa = PBXTargetDependency;",
        f"\t\t\ttarget = {IDS['main_target']} /* {PROJECT_NAME} */;",
        f"\t\t\ttargetProxy = {proxy} /* PBXContainerItemProxy */;",
        "\t\t};",
        f"\t\t{proxy} /* PBXContainerItemProxy */ = {{",
        "\t\t\tisa = PBXContainerItemProxy;",
        f"\t\t\tcontainerPortal = {IDS['project']} /* Project object */;",
        "\t\t\tproxyType = 1;",
        f"\t\t\tremoteGlobalIDString = {IDS['main_target']};",
        "\t\t\tremoteInfo = Chambea;",
        "\t\t};",
    ]
lines.append("/* End PBXNativeTarget section */")

lines.append("\n/* Begin PBXProject section */")
lines.append(f"\t\t{IDS['project']} /* Project object */ = {{")
lines.append("\t\t\tisa = PBXProject;")
lines.append(f"\t\t\tbuildConfigurationList = {IDS['proj_config_list']};")
lines.append("\t\t\tcompatibilityVersion = \"Xcode 14.0\";")
lines.append("\t\t\tdevelopmentRegion = es;")
lines.append("\t\t\thasScannedForEncodings = 0;")
lines.append("\t\t\tknownRegions = (es, en, pt, Base);")
lines.append(f"\t\t\tmainGroup = {IDS['main_group']};")
lines.append(f"\t\t\tproductRefGroup = {IDS['products_group']};")
lines.append("\t\t\tprojectDirPath = \"\";")
lines.append("\t\t\tprojectRoot = \"\";")
lines.append("\t\t\ttargets = (")
lines.append(f"\t\t\t\t{IDS['main_target']} /* {PROJECT_NAME} */,")
lines.append(f"\t\t\t\t{IDS['test_target']} /* {PROJECT_NAME}Tests */,")
lines.append(f"\t\t\t\t{IDS['ui_test_target']} /* {PROJECT_NAME}UITests */,")
lines.append("\t\t\t);")
lines.append("\t\t};")
lines.append("/* End PBXProject section */")

for phase_id, items in [
    (IDS["resources_phase"], build_files[IDS["resources_phase"]]),
    (IDS["sources_phase"], build_files[IDS["sources_phase"]]),
    (IDS["test_sources_phase"], build_files[IDS["test_sources_phase"]]),
    (IDS["ui_test_sources_phase"], build_files[IDS["ui_test_sources_phase"]]),
]:
    section = "PBXResourcesBuildPhase" if phase_id == IDS["resources_phase"] else "PBXSourcesBuildPhase"
    lines.append(f"\n/* Begin {section} section */")
    lines.append(f"\t\t{phase_id} /* {'Resources' if '08' in phase_id else 'Sources'} */ = {{")
    lines.append(f"\t\t\tisa = {section};")
    lines.append("\t\t\tbuildActionMask = 2147483647;")
    lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    lines.append("\t\t\tfiles = (")
    for build_id, _, path in items:
        lines.append(f"\t\t\t\t{build_id} /* {path.name} */,")
    lines.append("\t\t\t);")
    lines.append("\t\t};")
    lines.append(f"/* End {section} section */")

def config_block(cid: str, name: str, settings: list[str]) -> list[str]:
    out = [f"\t\t{cid} /* {name} */ = {{", "\t\t\tisa = XCBuildConfiguration;", "\t\t\tbuildSettings = {"]
    out += [f"\t\t\t\t{s}" for s in settings]
    out += ["\t\t\t};", f"\t\t\tname = {name};", "\t\t};"]
    return out

proj_settings = ["ALWAYS_SEARCH_USER_PATHS = NO;", "CLANG_ENABLE_MODULES = YES;", "IPHONEOS_DEPLOYMENT_TARGET = 17.0;", "SDKROOT = iphoneos;", "SWIFT_VERSION = 5.0;"]
app_settings = [
    "ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;",
    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;",
    "CODE_SIGN_STYLE = Automatic;",
    "CURRENT_PROJECT_VERSION = 1;",
    'DEVELOPMENT_TEAM = "";',
    "ENABLE_PREVIEWS = YES;",
    "GENERATE_INFOPLIST_FILE = NO;",
    "INFOPLIST_FILE = Chambea/Resources/Info.plist;",
    "IPHONEOS_DEPLOYMENT_TARGET = 17.0;",
    'LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/Frameworks");',
    "MARKETING_VERSION = 1.0.0;",
    f"PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};",
    'PRODUCT_NAME = "$(TARGET_NAME)";',
    "SDKROOT = iphoneos;",
    "SWIFT_EMIT_LOC_STRINGS = YES;",
    "SWIFT_VERSION = 5.0;",
    'TARGETED_DEVICE_FAMILY = "1";',
]
test_settings = [
    'BUNDLE_LOADER = "$(TEST_HOST)";',
    "CODE_SIGN_STYLE = Automatic;",
    "GENERATE_INFOPLIST_FILE = YES;",
    "IPHONEOS_DEPLOYMENT_TARGET = 17.0;",
    f"PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID}.tests;",
    'PRODUCT_NAME = "$(TARGET_NAME)";',
    "SDKROOT = iphoneos;",
    "SWIFT_VERSION = 5.0;",
    'TARGETED_DEVICE_FAMILY = "1";',
    'TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Chambea.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Chambea";',
]
debug = ["DEBUG_INFORMATION_FORMAT = dwarf;", "GCC_DYNAMIC_NO_PIC = NO;", "GCC_OPTIMIZATION_LEVEL = 0;", "ONLY_ACTIVE_ARCH = YES;", "SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;", 'SWIFT_OPTIMIZATION_LEVEL = "-Onone";']
release = ['DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";', "VALIDATE_PRODUCT = YES;"]

lines.append("\n/* Begin XCBuildConfiguration section */")
lines += config_block(IDS["proj_debug"], "Debug", proj_settings + debug)
lines += config_block(IDS["proj_release"], "Release", proj_settings + release)
lines += config_block(IDS["main_debug"], "Debug", app_settings + debug)
lines += config_block(IDS["main_release"], "Release", app_settings + release)
lines += config_block(IDS["test_debug"], "Debug", test_settings + debug)
lines += config_block(IDS["test_release"], "Release", test_settings + release)
lines += config_block(IDS["ui_test_debug"], "Debug", [s.replace(".tests", ".uitests") for s in test_settings] + debug)
lines += config_block(IDS["ui_test_release"], "Release", [s.replace(".tests", ".uitests") for s in test_settings] + release)
lines.append("/* End XCBuildConfiguration section */")

lines.append("\n/* Begin XCConfigurationList section */")
for clist, cfgs in [
    (IDS["proj_config_list"], [(IDS["proj_debug"], "Debug"), (IDS["proj_release"], "Release")]),
    (IDS["main_config_list"], [(IDS["main_debug"], "Debug"), (IDS["main_release"], "Release")]),
    (IDS["test_config_list"], [(IDS["test_debug"], "Debug"), (IDS["test_release"], "Release")]),
    (IDS["ui_test_config_list"], [(IDS["ui_test_debug"], "Debug"), (IDS["ui_test_release"], "Release")]),
]:
    lines.append(f"\t\t{clist} /* Build configuration list */ = {{")
    lines.append("\t\t\tisa = XCConfigurationList;")
    lines.append("\t\t\tbuildConfigurations = (")
    for cid, cname in cfgs:
        lines.append(f"\t\t\t\t{cid} /* {cname} */,")
    lines.append("\t\t\t);")
    lines.append("\t\t\tdefaultConfigurationIsVisible = 0;")
    lines.append("\t\t\tdefaultConfigurationName = Release;")
    lines.append("\t\t};")
lines.append("/* End XCConfigurationList section */")

lines += ["\t};", f"\trootObject = {IDS['project']} /* Project object */;", "}"]

out = ROOT / f"{PROJECT_NAME}.xcodeproj"
out.mkdir(exist_ok=True)
(out / "project.pbxproj").write_text("\n".join(lines))

# Scheme
scheme_dir = out / "xcshareddata" / "xcschemes"
scheme_dir.mkdir(parents=True, exist_ok=True)
scheme_dir.joinpath(f"{PROJECT_NAME}.xcscheme").write_text(f"""<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Scheme LastUpgradeVersion=\"1500\" version=\"1.7\">
  <BuildAction parallelizeBuildables=\"YES\" buildImplicitDependencies=\"YES\">
    <BuildActionEntries>
      <BuildActionEntry buildForTesting=\"YES\" buildForRunning=\"YES\" buildForProfiling=\"YES\" buildForArchiving=\"YES\" buildForAnalyzing=\"YES\">
        <BuildableReference BuildableIdentifier=\"primary\" BlueprintIdentifier=\"{IDS['main_target']}\" BuildableName=\"{PROJECT_NAME}.app\" BlueprintName=\"{PROJECT_NAME}\" ReferencedContainer=\"container:{PROJECT_NAME}.xcodeproj\"/>
      </BuildActionEntry>
    </BuildActionEntries>
  </BuildAction>
  <TestAction buildConfiguration=\"Debug\" selectedDebuggerIdentifier=\"Xcode.DebuggerFoundation.Debugger.LLDB\" selectedLauncherIdentifier=\"Xcode.DebuggerFoundation.Launcher.LLDB\">
    <Testables>
      <TestableReference skipped=\"NO\">
        <BuildableReference BuildableIdentifier=\"primary\" BlueprintIdentifier=\"{IDS['test_target']}\" BuildableName=\"{PROJECT_NAME}Tests.xctest\" BlueprintName=\"{PROJECT_NAME}Tests\" ReferencedContainer=\"container:{PROJECT_NAME}.xcodeproj\"/>
      </TestableReference>
    </Testables>
  </TestAction>
  <LaunchAction buildConfiguration=\"Debug\" selectedDebuggerIdentifier=\"Xcode.DebuggerFoundation.Debugger.LLDB\" selectedLauncherIdentifier=\"Xcode.DebuggerFoundation.Launcher.LLDB\" launchStyle=\"0\" useCustomWorkingDirectory=\"NO\">
    <BuildableProductRunnable runnableDebuggingMode=\"0\">
      <BuildableReference BuildableIdentifier=\"primary\" BlueprintIdentifier=\"{IDS['main_target']}\" BuildableName=\"{PROJECT_NAME}.app\" BlueprintName=\"{PROJECT_NAME}\" ReferencedContainer=\"container:{PROJECT_NAME}.xcodeproj\"/>
    </BuildableProductRunnable>
  </LaunchAction>
</Scheme>
""")
print("Generated project successfully")