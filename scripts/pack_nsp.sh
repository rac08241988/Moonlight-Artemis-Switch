#!/bin/bash
# Artemis Switch: build Moonlight.elf -> installable NSP (title 0100A7E3A7E00000)
# Keys: pass the PATH to your own prod.keys only. Never commit or print them.
set -euo pipefail
# Usage: KEYS=/path/to/your/prod.keys HACBREWPACK=/path/to/hacbrewpack scripts/pack_nsp.sh
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=$ROOT
BUILD=$SRC/build/switch
DKP=${DEVKITPRO:-/opt/devkitpro}
TID=0100a7e3a7e00000
NAME="Moonlight Artemis"
AUTHOR="Randall Campbell"
VERSION=$(cat $ROOT/VERSION)
KEYS=${KEYS:-$HOME/.switch/prod.keys}   # your own keys; never commit them
HBP=${HACBREWPACK:-hacbrewpack}
W=$ROOT/build/nsp-work
OUT=$ROOT/out

export DEVKITPRO=$DKP
ninja -C "$BUILD" Moonlight.nro

rm -rf "$W"; mkdir -p "$W"/{exefs,romfs,control} "$OUT"
$DKP/tools/bin/elf2nso "$BUILD/Moonlight.elf" "$W/exefs/main"
$DKP/tools/bin/npdmtool "$ROOT/scripts/npdm.json" "$W/exefs/main.npdm"

# RomFS = same resources the .nro embeds (font dir excluded, shared font used)
cp -r "$BUILD/resources/." "$W/romfs/"
rm -rf "$W/romfs/font"

# Control: NACP + icon
$DKP/tools/bin/nacptool --create "$NAME" "$AUTHOR" "$VERSION" "$W/control/control.nacp" --titleid=0x$TID
python3 - "$W/control/control.nacp" <<'PY'
import sys
p=sys.argv[1]; d=bytearray(open(p,'rb').read())
assert len(d)==0x4000
d[0x3025]=1      # StartupUserAccount: Required (matches working Demon's Crest NSP)
d[0x3034]=0      # Screenshot: Allow
d[0x3035]=0      # VideoCapture: Disable (1.0.4: Enable made "am" fatal 2128-0007 at launch; matches Demon's Crest)
open(p,'wb').write(d)
PY
python3 -c "
from PIL import Image
Image.open('$SRC/resources/img/moonlight_icon.jpg').convert('RGB').resize((256,256)).save('$W/control/icon_AmericanEnglish.dat','JPEG',quality=95)"

cd "$W"
"$HBP" -k "$KEYS" --titleid $TID --titlename "$NAME" --titlepublisher "$AUTHOR" \
    --nologo --exefsdir exefs --romfsdir romfs --controldir control \
    --nspdir nsp --tempdir tmp --backupdir backup > "$W/hacbrewpack.log" 2>&1
NSP=$(ls nsp/*.nsp | head -1)
cp "$NSP" "$OUT/MoonlightArtemis-$VERSION.nsp"
echo "NSP: $OUT/MoonlightArtemis-$VERSION.nsp"
