"""Response-envelope helpers every router uses so the JSON shape is uniform
(ADR 0101): success responses are {"data": ...} and errors are
{"error": {"code": ..., "message": ...}}."""

from fastapi.responses import JSONResponse


def ok(data: dict, status: int = 200) -> JSONResponse:
    return JSONResponse({"data": data}, status_code=status)


def fail(code: str, message: str, status: int = 400) -> JSONResponse:
    return JSONResponse(
        {"error": {"code": code, "message": message}}, status_code=status
    )
