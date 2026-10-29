from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from .model import Notation, Movetable, Findmove
from .notation import get_img_notation
from .movetable import get_movetable, finding_move, finding_similiar_move, get_version
import io

app = FastAPI()


@app.get("/")
async def movetable():
    result = await get_version()
    if isinstance(result, dict) and "error" in result:
        raise HTTPException(status_code=502, detail=result["error"])
    return {"detail": "Using" + result[0]}


@app.post("/movetable")
async def movetable(data: Movetable):
    result = await get_movetable(data)
    if isinstance(result, dict) and "error" in result:
        raise HTTPException(status_code=502, detail=result["error"])
    return {"total_data": len(result), "data": result}


@app.post("/findmove")
async def findmove(data: Findmove):
    main_result = await finding_move(data)
    if isinstance(main_result, dict) and "error" in main_result:
        raise HTTPException(status_code=502, detail=main_result["error"])
    similiar = await finding_similiar_move(data)
    if isinstance(similiar, dict) and "error" in similiar:
        raise HTTPException(status_code=502, detail=similiar["error"])
    return {
        "total_data": (
            len(main_result) if isinstance(main_result, list) else len(similiar)
        ),
        "data": main_result,
        "similiar": similiar,
    }


@app.post("/notation")
async def notation(data: Notation):
    notation_img = await get_img_notation(data)
    if isinstance(notation_img, dict):
        return notation_img
    img_byte_array = io.BytesIO()
    notation_img.save(img_byte_array, format="PNG")
    img_byte_array.seek(0)
    return StreamingResponse(img_byte_array, media_type="image/png")
