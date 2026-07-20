<div class="card shadow-sm border-0 form-shell mx-auto">
    <div class="card-header"><h1 class="h4 mb-0">Consultar usuario</h1></div>
    <div class="card-body">
        <?php if (!empty($error)): ?><div class="alert alert-warning"><?= e((string) $error) ?></div>
        <?php else: $datos = $usuario['datos'] ?? []; ?>
            <dl class="row mb-4"><dt class="col-sm-4">Usuario</dt><dd class="col-sm-8"><?= e($datos['usuario'] ?? '') ?></dd><dt class="col-sm-4">Nombre completo</dt><dd class="col-sm-8"><?= e($datos['nombreCompleto'] ?? '') ?></dd><dt class="col-sm-4">Correo</dt><dd class="col-sm-8"><?= e($datos['correo'] ?? '') ?></dd><dt class="col-sm-4">Rol</dt><dd class="col-sm-8"><?= e($datos['rol'] ?? '') ?></dd><dt class="col-sm-4">Estado</dt><dd class="col-sm-8"><?= e(ucfirst($datos['estado'] ?? '')) ?></dd></dl>
        <?php endif; ?>
        <a class="btn btn-secondary" href="<?= e(url('usuarios')) ?>">Regresar</a>
    </div>
</div>
