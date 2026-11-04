#!/usr/bin/env python3
"""Captures d'écran du README, prises sur un téléphone Android branché.

Usage : python3 tool/screenshots.py [--device SERIAL]

Prérequis :
- l'application en release installée (`adb install -r`, jamais
  `flutter install`, qui efface les données) ;
- le téléphone déverrouillé, écran allumé, en français ;
- une liste de courses non vide avec quelques produits cochés.

Le script ne modifie aucune donnée : il navigue, fait défiler et capture.
Les éléments sont trouvés par leur libellé d'accessibilité (uiautomator),
pas par coordonnées. Les barres d'état et de navigation sont rognées.
Résultat : docs/screenshots/*.png.
"""

import argparse
import os
import re
import subprocess
import sys
import time
from io import BytesIO

from PIL import Image

PACKAGE = "com.yumly.yumly"
RECIPE_QUERY = "tikka"
RECIPE_TITLE = "Poulet tikka massala"
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "docs", "screenshots")
OUT_WIDTH = 540
ADB = os.environ.get("ADB") or os.path.expanduser("~/Android/Sdk/platform-tools/adb")

serial = None


def adb(*args, binary=False):
    cmd = [ADB] + (["-s", serial] if serial else []) + list(args)
    out = subprocess.run(cmd, check=True, capture_output=True).stdout
    return out if binary else out.decode("utf-8", "replace")


def nodes():
    """Libellés visibles et leurs bornes [(label, (x1, y1, x2, y2))]."""
    adb("shell", "uiautomator", "dump", "/sdcard/yumly_ui.xml")
    xml = adb("shell", "cat", "/sdcard/yumly_ui.xml")
    result = []
    for node in re.findall(r"<node [^>]*>", xml):
        label = re.search(r'content-desc="([^"]*)"', node).group(1) or \
            re.search(r'text="([^"]*)"', node).group(1)
        b = re.search(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', node)
        if label and b:
            label = label.replace("&#10;", "\n").replace("&amp;", "&")
            result.append((label, tuple(map(int, b.groups()))))
    return result


def find(pattern):
    for label, bounds in nodes():
        if re.fullmatch(pattern, label, re.S):
            return bounds
    return None


def wait_for(pattern, timeout=10):
    end = time.time() + timeout
    while time.time() < end:
        bounds = find(pattern)
        if bounds:
            return bounds
        time.sleep(0.5)
    sys.exit(f"Élément introuvable : {pattern!r}")


def tap(pattern):
    x1, y1, x2, y2 = wait_for(pattern)
    adb("shell", "input", "tap", str((x1 + x2) // 2), str((y1 + y2) // 2))
    time.sleep(1.5)


def tap_search_field():
    adb("shell", "uiautomator", "dump", "/sdcard/yumly_ui.xml")
    xml = adb("shell", "cat", "/sdcard/yumly_ui.xml")
    node = re.search(r'<node [^>]*class="android.widget.EditText"[^>]*>', xml)
    if not node:
        sys.exit("Champ de recherche introuvable")
    x1, y1, x2, y2 = map(int, re.search(
        r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', node.group(0)).groups())
    adb("shell", "input", "tap", str((x1 + x2) // 2), str((y1 + y2) // 2))
    time.sleep(1)


def screen_size():
    w, h = re.search(r"(\d+)x(\d+)", adb("shell", "wm", "size")).groups()
    return int(w), int(h)


def scroll_to_top_of(pattern, top):
    """Fait défiler jusqu'à placer l'élément à `top` pixels du haut, ou
    jusqu'en bas de la page si elle se termine avant."""
    w, h = screen_size()
    previous = None
    for _ in range(15):
        bounds = find(pattern)
        if bounds is None:
            # Pas encore visible : on descend d'un tiers d'écran, lentement.
            adb("shell", "input", "swipe", str(w // 2), str(h * 2 // 3),
                str(w // 2), str(h // 3), "1500")
            time.sleep(1)
            continue
        delta = bounds[1] - top
        if abs(delta) < 15 or bounds == previous:
            return
        previous = bounds
        start = h * 3 // 4 if delta > 0 else h // 4
        # Glissement lent pour éviter l'inertie.
        adb("shell", "input", "swipe", str(w // 2), str(start),
            str(w // 2), str(start - delta), "1500")
        time.sleep(1)
    sys.exit(f"Impossible de placer {pattern!r} en haut de l'écran")


def capture(name, crop_top, crop_bottom):
    time.sleep(1)
    png = adb("exec-out", "screencap", "-p", binary=True)
    img = Image.open(BytesIO(png)).convert("RGB")
    img = img.crop((0, crop_top, img.width, crop_bottom))
    ratio = OUT_WIDTH / img.width
    img = img.resize((OUT_WIDTH, round(img.height * ratio)), Image.LANCZOS)
    path = os.path.normpath(os.path.join(OUT_DIR, f"{name}.png"))
    img.save(path, optimize=True)
    print(f"{path} ({os.path.getsize(path) // 1024} Ko)")


def main():
    global serial
    parser = argparse.ArgumentParser()
    parser.add_argument("--device")
    serial = parser.parse_args().device
    os.makedirs(OUT_DIR, exist_ok=True)

    if "mShowingLockscreen=true" in adb("shell", "dumpsys", "window") or \
            "isKeyguardShowing=true" in adb("shell", "dumpsys", "window"):
        sys.exit("Le téléphone est verrouillé : le déverrouiller puis relancer.")

    adb("shell", "am", "force-stop", PACKAGE)
    adb("shell", "monkey", "-p", PACKAGE, "-c",
        "android.intent.category.LAUNCHER", "1")
    tab_bar = wait_for(r"Accueil\nOnglet 1 sur 4")
    # Rognage : sous la barre d'état, jusqu'au bas de la barre d'onglets.
    top = wait_for(r"Yumly")[1] - 20
    bottom = tab_bar[3]

    capture("1-accueil", top, bottom)

    # Détail d'une recette, via la recherche.
    tap_search_field()
    adb("shell", "input", "text", RECIPE_QUERY)
    adb("shell", "input", "keyevent", "111")  # Échap : ferme le clavier.
    time.sleep(1)
    tap(re.escape(RECIPE_TITLE) + r"\n.*")
    wait_for(re.escape(RECIPE_TITLE))
    capture("2-recette", top, bottom)

    # Marge sous la barre du haut, opaque une fois la page défilée.
    content_top = wait_for(r"Retour")[3] + 80
    scroll_to_top_of(r"Ingrédients", content_top)
    capture("3-ingredients", top, bottom)

    scroll_to_top_of(r"Préparation", content_top)
    capture("4-preparation", top, bottom)

    # Liste de courses : recettes, puis produits (avec les cases cochées).
    tap(r"(\d+\n)?Courses\nOnglet 3 sur 4")
    wait_for(r"Liste de courses")
    capture("5-liste-de-courses", top, bottom)

    tap(r"Voir les ingrédients à acheter")
    wait_for(r"Ingrédients à acheter")
    capture("6-ingredients-a-acheter", top, bottom)

    # Remet l'application sur l'accueil, recherche effacée.
    adb("shell", "input", "keyevent", "4")
    tap(r"Accueil\nOnglet 1 sur 4")
    if find(r"Retour"):
        tap(r"Retour")
    if find(r"Effacer la recherche"):
        tap(r"Effacer la recherche")


if __name__ == "__main__":
    main()
