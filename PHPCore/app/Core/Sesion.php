<?php

declare(strict_types=1);

namespace App\Core;

final class Sesion
{
    private function __construct()
    {
    }

    public static function start(): void
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start([
                'cookie_httponly' => true,
                'cookie_samesite' => 'Lax',
                'use_strict_mode' => true,
            ]);
        }
    }

    public static function flash(string $key, mixed $value): void
    {
        $_SESSION['_flash'][$key] = $value;
    }

    public static function getFlash(string $key, mixed $default = null): mixed
    {
        $value = $_SESSION['_flash'][$key] ?? $default;
        unset($_SESSION['_flash'][$key]);

        return $value;
    }

    public static function csrfToken(): string
    {
        if (empty($_SESSION['_csrf'])) {
            $_SESSION['_csrf'] = bin2hex(random_bytes(32));
        }

        return $_SESSION['_csrf'];
    }

    public static function verifyCsrf(?string $token): bool
    {
        return is_string($token)
            && hash_equals(self::csrfToken(), $token);
    }

    public static function iniciarAutenticacion(array $usuario): void
    {
        session_regenerate_id(true);
        $_SESSION['autenticacion'] = [
            'autenticado' => true,
            'id_usuario' => (int) ($usuario['idUsuario'] ?? 0),
            'usuario' => (string) ($usuario['usuario'] ?? ''),
            'nombre_completo' => (string) ($usuario['nombreCompleto'] ?? ''),
            'id_rol' => (int) ($usuario['idRol'] ?? 0),
            'nombre_rol' => (string) ($usuario['nombreRol'] ?? ''),
            'estado' => (string) ($usuario['estado'] ?? ''),
        ];
    }

    public static function estaAutenticado(): bool
    {
        return ($_SESSION['autenticacion']['autenticado'] ?? false) === true;
    }

    public static function usuario(): array
    {
        return is_array($_SESSION['autenticacion'] ?? null) ? $_SESSION['autenticacion'] : [];
    }

    public static function usuarioId(): int
    {
        return (int) (self::usuario()['id_usuario'] ?? 0);
    }

    public static function esAdministrador(): bool
    {
        $usuario = self::usuario();
        $rol = mb_strtolower(trim((string) ($usuario['nombre_rol'] ?? '')));

        return (int) ($usuario['id_rol'] ?? 0) === 1
            || str_contains($rol, 'admin');
    }

    public static function requerirAutenticacion(): void
    {
        if (!self::estaAutenticado()) {
            self::flash('error', 'Por favor inicie sesión para utilizar el sistema');
            redirect(url('login'));
        }
    }

    public static function cerrar(): void
    {
        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $parametros = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000, $parametros['path'], $parametros['domain'], $parametros['secure'], $parametros['httponly']);
        }
        if (session_status() === PHP_SESSION_ACTIVE) {
            session_destroy();
        }
    }
}

