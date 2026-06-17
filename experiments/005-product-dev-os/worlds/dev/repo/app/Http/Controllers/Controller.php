<?php

namespace App\Http\Controllers;

// Base controller. Provides the response-envelope helpers every controller
// uses so the JSON shape is uniform (ADR 0001): success responses are
// {"data": ...} and errors are {"error": {"code": ..., "message": ...}}.
abstract class Controller
{
    protected function ok(array $data, int $status = 200)
    {
        return response()->json(['data' => $data], $status);
    }

    protected function fail(string $code, string $message, int $status = 400)
    {
        return response()->json([
            'error' => ['code' => $code, 'message' => $message],
        ], $status);
    }
}
