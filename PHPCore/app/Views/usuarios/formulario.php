<div class="card shadow-sm border-0 form-shell mx-auto">
    <div class="card-header"><h1 class="h4 mb-0"><?= $modo === 'editar' ? 'Editar usuario' : 'Crear usuario' ?></h1></div>
    <div class="card-body">
        <?php if (!empty($error)): ?><div class="alert alert-danger"><?= e((string) $error) ?></div><?php endif; ?>
        <?php if (!empty($exito)): ?><div class="alert alert-success"><?= e((string) $exito) ?></div><?php endif; ?>
        <form method="post" action="<?= e($modo === 'editar' ? url('usuarios-editar', ['id' => $datos['id'] ?? 0]) : url('usuarios-crear')) ?>">
            <input type="hidden" name="_csrf" value="<?= e($csrf ?? '') ?>">
            <div class="row g-3">
                <div class="col-md-6"><label class="form-label" for="usuario">Usuario</label><input class="form-control" id="usuario" name="usuario" maxlength="50" value="<?= e($datos['usuario'] ?? '') ?>" required></div>
                <div class="col-md-6"><label class="form-label" for="password">Contraseña<?= $modo === 'editar' ? ' (dejar vacía para conservar)' : '' ?></label><input class="form-control" id="password" name="password" type="password" minlength="8" <?= $modo === 'crear' ? 'required' : '' ?>></div>
                <div class="col-md-6"><label class="form-label" for="nombreCompleto">Nombre completo</label><input class="form-control" id="nombreCompleto" name="nombreCompleto" maxlength="150" value="<?= e($datos['nombreCompleto'] ?? '') ?>" required></div>
                <div class="col-md-6"><label class="form-label" for="correo">Correo</label><input class="form-control" id="correo" name="correo" type="email" maxlength="150" value="<?= e($datos['correo'] ?? '') ?>" required></div>
                <div class="col-md-6"><label class="form-label" for="rol">Rol</label><input class="form-control" id="rol" name="rol" maxlength="50" value="<?= e($datos['rol'] ?? '') ?>" required></div>
                <div class="col-md-6"><label class="form-label" for="estado">Estado</label><select class="form-select" id="estado" name="estado" required><option value="activo" <?= ($datos['estado'] ?? 'activo') === 'activo' ? 'selected' : '' ?>>Activo</option><option value="inactivo" <?= ($datos['estado'] ?? '') === 'inactivo' ? 'selected' : '' ?>>Inactivo</option></select></div>
            </div>
            <div class="mt-4 d-flex gap-2"><button class="btn btn-primary" type="submit">Guardar</button><a class="btn btn-secondary" href="<?= e(url('usuarios')) ?>">Regresar</a></div>
        </form>
    </div>
</div>
