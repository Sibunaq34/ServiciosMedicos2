<div class="card shadow-sm border-0">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h1 class="h4 mb-0">Administración de usuarios</h1>
        <a class="btn btn-primary btn-sm" href="<?= e(url('usuarios-crear')) ?>">Crear usuario</a>
    </div>
    <div class="card-body">
        <?php if (!empty($error)): ?><div class="alert alert-danger"><?= e((string) $error) ?></div><?php endif; ?>
        <?php if (!empty($exito)): ?><div class="alert alert-success"><?= e((string) $exito) ?></div><?php endif; ?>
        <?php if (empty($error) && empty($usuarios)): ?><div class="alert alert-info mb-0">No hay usuarios registrados.</div>
        <?php elseif (!empty($usuarios)): ?>
        <div class="table-responsive"><table class="table table-hover align-middle">
            <thead><tr><th>Usuario</th><th>Nombre</th><th>Correo</th><th>Rol</th><th>Estado</th><th class="text-end">Acciones</th></tr></thead>
            <tbody><?php foreach ($usuarios as $usuario): ?><?php $activo = strtolower((string) ($usuario['estado'] ?? '')) === 'activo'; ?>
                <tr>
                    <td><?= e($usuario['usuario'] ?? '') ?></td><td><?= e($usuario['nombreCompleto'] ?? '') ?></td>
                    <td><?= e($usuario['correo'] ?? '') ?></td><td><?= e($usuario['rol'] ?? '') ?></td>
                    <td><span class="badge <?= $activo ? 'text-bg-success' : 'text-bg-secondary' ?>"><?= $activo ? 'Activo' : 'Inactivo' ?></span></td>
                    <td class="text-end text-nowrap">
                        <a class="btn btn-outline-secondary btn-sm" href="<?= e(url('usuarios-consultar', ['id' => $usuario['id'] ?? 0])) ?>">Consultar</a>
                        <a class="btn btn-outline-primary btn-sm" href="<?= e(url('usuarios-editar', ['id' => $usuario['id'] ?? 0])) ?>">Editar</a>
                        <form class="d-inline" method="post" action="<?= e(url('usuarios-estado')) ?>" data-confirm="<?= e($activo ? '¿Confirma que desea inactivar este usuario?' : '¿Confirma que desea activar este usuario?') ?>">
                            <input type="hidden" name="_csrf" value="<?= e(\App\Core\Sesion::csrfToken()) ?>"><input type="hidden" name="id" value="<?= (int) ($usuario['id'] ?? 0) ?>"><input type="hidden" name="estado" value="<?= $activo ? 'inactivo' : 'activo' ?>">
                            <button class="btn btn-sm <?= $activo ? 'btn-outline-danger' : 'btn-outline-success' ?>" type="submit"><?= $activo ? 'Inactivar' : 'Activar' ?></button>
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?></tbody>
        </table></div>
        <?php endif; ?>
    </div>
</div>
