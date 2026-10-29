from bs4 import BeautifulSoup
from .model import Movetable, Findmove
from difflib import get_close_matches
import requests, re, random, time, json

_MOVETABLE_CACHE = {}
_MOVETABLE_CACHE_TTL = 6 * 60 * 60


# Converting for searching moveset
def convert_moveset(move: str):
    move = move.replace("WR", "f,f,F+")
    move = move.replace("wr", "f,f,F+")
    move = move.replace("WS", "ws")
    move = re.sub(r"ewgf", "f,n,d,df:2", move, flags=re.IGNORECASE)
    move = move.replace("RA", "R.df+1+2")
    move = move.replace("HS", "H.2+3")
    move = move.replace("HB", "2+3")
    return move


def normalize_moveset(move: str):
    # Tekken Frame Data uses d/f and u/f; accept the compact forms commonly
    # typed into this app while preserving : for a just-input command.
    move = re.sub(r"([ud])/([fb])", r"\1\2", move, flags=re.IGNORECASE)
    return move.lower()


async def finding_similiar_move(param: Findmove):
    # Makro for character name
    if param.character_name == "DVJ" or param.character_name == "dvj":
        param.character_name = "Devil Jin"
    data = await get_movetable(Findmove(character_name=param.character_name))
    if isinstance(data, dict) and "error" in data:
        return data
    param.notation = convert_moveset(param.notation)

    if param.notation:
        moveset_matches = get_close_matches(
            param.notation,
            [
                normalize_moveset(item["moveset"].replace(f"{param.character_name.title()}-", ""))
                for item in data
            ],
            n=5,
            cutoff=0.6,
        )
        filtered_result = [
            item
            for item in data
            if normalize_moveset(item["moveset"].replace(f"{param.character_name.title()}-", ""))
            in moveset_matches
        ]
    elif param.name_move:
        closest_name_move = get_close_matches(
            param.name_move.title(),
            [item["name_move"] for item in data],
            n=5,
            cutoff=0.6,
        )
        filtered_result = [
            item for item in data if item["name_move"] in closest_name_move
        ]
    return (
        filtered_result
        if filtered_result
        else {"error": "No matching moveset found", "param": param}
    )


async def finding_move(param: Findmove):
    # Makro for character name
    if param.character_name == "DVJ" or param.character_name == "dvj":
        param.character_name = "Devil Jin"

    data = await get_movetable(Findmove(character_name=param.character_name))
    if isinstance(data, dict) and "error" in data:
        return data
    param.notation = convert_moveset(param.notation)
    # If notation is provided, perform an exact match on "moveset"
    if param.notation:
        if "stance" in param.notation:
            # Get value inside parentheses in "stance(...)" and store that value
            stance = re.search(r"\((.*?)\)", param.notation).group(1)
            # Change text stance(...) in param.notation to variabel stance previously created
            param.notation = param.notation.replace(f"stance({stance})", stance)

            # Split converted_move with comma (,)
            converted_moves = param.notation.split(",")
            # And search the value in raw_data with conditions if len(converted_moves) == raw_data["moveset"]
            filtered_result = [
                item
                for item in data
                if all(
                    move
                    in normalize_moveset(item["moveset"]
                    .replace(f"{param.character_name.title()}-", ""))
                    .split(",")
                    and len(
                        normalize_moveset(item["moveset"]
                        .replace(f"{param.character_name.title()}-", ""))
                        .split(",")
                    )
                    == len(converted_moves)
                    for move in converted_moves
                )
            ]
        else:
            target_moveset = f"{param.character_name.title()}-{param.notation}"
            # Search value target in raw_data
            filtered_result = [item for item in data if normalize_moveset(item["moveset"]) == normalize_moveset(target_moveset)]
    elif param.name_move:
        name_move_target = param.name_move.title()
        name_filtered = get_close_matches(
            name_move_target,
            [item["name_move"] for item in data],
            n=10,
            cutoff=0.6,
        )
        filtered_result = [item for item in data if item["name_move"] in name_filtered]

    # Return filtered results or an error if none found
    return (
        filtered_result
        if filtered_result
        else {"error": "No matching moveset found", "param": param}
    )


async def get_starter_frame(character_name: str, notation: str):
    # Makro for character name
    if character_name == "DVJ" or character_name == "dvj":
        character_name = "Devil Jin"

    notation = notation.replace(".", ",")
    raw_data = await get_movetable(Movetable(character_name=character_name))
    if "error" in raw_data:
        return raw_data
    converted_move = convert_moveset(notation)

    # Split converted_move with spaces and get the first part if part have a digit (have action)
    converted_move = next(
        (part for part in converted_move.split(" ") if re.search(r"\d", part)), ""
    )
    if not converted_move:
        return {"error": "No move notation found", "character_name": character_name}

    # This condition if in notation using stance
    if "stance" in converted_move:
        # Get value inside parentheses in "stance(...)" and store that value
        stance = re.search(r"\((.*?)\)", converted_move).group(1)
        # Change text stance(...) in converted_move to variabel stance previously created
        converted_move = converted_move.replace(f"stance({stance})", stance)

        # Split converted_move with comma (,)
        converted_moves = converted_move.split(",")
        # And search the value in raw_data with conditions if len(converted_moves) == raw_data["moveset"]
        filtered_result = [
            item
            for item in raw_data
            if all(
                move
                in item["moveset"]
                .replace(f"{character_name.title()}-", "")
                .replace(".", ",")
                .split(",")
                and len(
                    item["moveset"]
                    .replace(f"{character_name.title()}-", "")
                    .replace(".", ",")
                    .split(",")
                )
                == len(converted_moves)
                for move in converted_moves
            )
        ]

    # If not using any stance in notation
    else:
        target_moveset = f"{character_name.title()}-{converted_move}"
        # Search value target in raw_data
        filtered_result = [
            item for item in raw_data if normalize_moveset(item["moveset"]) == normalize_moveset(target_moveset)
        ]

    return (
        filtered_result
        if filtered_result
        else {
            "error": f"No matching moveset found for {converted_move}",
            "character_name": character_name,
            "notation": notation,
        }
    )


async def get_version():
    url = f"https://wavu.wiki/t/Main_Page"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    sleep_time_ms = random.randint(100, 300)
    sleep_time_sec = sleep_time_ms / 1000.0
    time.sleep(sleep_time_sec)

    try:
        response = requests.get(url, headers=headers, timeout=(5, 20))
    except requests.RequestException as exc:
        return {"error": f"Tidak dapat menghubungi WavuWiki: {exc}"}
    if response.status_code != 200:
        return {"error": f"WavuWiki mengembalikan HTTP {response.status_code} saat mengambil versi."}
    if response.status_code == 200:
        soup = BeautifulSoup(response.content, "html.parser")
        raw = soup.find(class_="floatright")
        if raw is None:
            return {"error": "Format halaman versi WavuWiki berubah."}
        result = [data for data in raw.get_text().split("\n") if "Version" in data]
        return result or {"error": "Versi tidak ditemukan di halaman WavuWiki."}


async def get_movetable(data: Movetable):
    # Makro for character name
    if data.character_name == "DVJ" or data.character_name == "dvj":
        data.character_name = "Devil Jin"
    # Tekken Frame Data publishes the current roster on accessible character pages.
    # Its page data is embedded in Next.js Flight JSON, so we read that payload
    # instead of calling WavuWiki's Cloudflare-protected Cargo endpoint.
    url_character_name = re.sub(r"[^a-z0-9]+", "-", data.character_name.lower()).strip("-")
    cached = _MOVETABLE_CACHE.get(url_character_name)
    if cached and time.time() - cached[0] < _MOVETABLE_CACHE_TTL:
        return cached[1]
    url = f"https://tekkenframedata.net/database/{url_character_name}"
    headers = {
        "User-Agent": "TekkenMoveGuide/1.0 (Android study app)",
        "Accept": "text/html,application/xhtml+xml",
    }
    try:
        response = requests.get(url, headers=headers, timeout=(5, 20))
    except requests.RequestException as exc:
        return {"error": f"Tidak dapat menghubungi WavuWiki: {exc}"}
    if response.status_code != 200:
        return {"error": f"Tekken Frame Data mengembalikan HTTP {response.status_code} untuk {data.character_name}."}

    soup = BeautifulSoup(response.content, "html.parser")
    moves = None
    for script in soup.find_all("script"):
        script_text = script.string or script.get_text()
        marker = "self.__next_f.push("
        if marker not in script_text:
            continue
        try:
            flight_chunk = json.loads(script_text[script_text.index(marker) + len(marker):script_text.rfind(")")])
            page_payload = flight_chunk[1]
            moves_key = page_payload.find('"moves":')
            moves_start = page_payload.find("[", moves_key)
            candidate, _ = json.JSONDecoder().raw_decode(page_payload[moves_start:])
            if isinstance(candidate, list) and candidate and isinstance(candidate[0], dict) and "cmd" in candidate[0]:
                moves = candidate
                break
        except (ValueError, IndexError, TypeError):
            continue

    if not moves:
        return {"error": f"Data jurus {data.character_name} tidak ditemukan pada Tekken Frame Data."}

    result = []
    for move in moves:
        command = move.get("cmd") or ""
        properties = [str(prop).replace("-", " ").title() for prop in move.get("props", [])]
        states = [str(state) for state in move.get("states", [])]
        result.append({
            "moveset": f"{data.character_name.title()}-{command}",
            "name_move": move.get("name") or "",
            "startup": move.get("st") or "",
            "hit_properties": move.get("hl") or "",
            "damage": move.get("dmg") or "",
            "on_block": move.get("ob") or "",
            "on_hit": move.get("oh") or "",
            "on_CH": "" if move.get("chn") is None else str(move["chn"]),
            "states": ", ".join(states + properties),
            "notes": move.get("notes") or "",
        })
    _MOVETABLE_CACHE[url_character_name] = (time.time(), result)
    return result
