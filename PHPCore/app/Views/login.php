<div class="row justify-content-center">
    <div class="col-sm-10 col-md-7 col-lg-5">
        <div class="card shadow-sm border-0"><div class="card-body p-4 p-lg-5">
            <div class="text-center mb-4">
                <i class="bi bi-people-fill fs-1 text-primary"></i>
                <h1 class="h3 mt-2">Servicios Médicos</h1>
                <p class="text-muted">Ingrese al sistema</p>
            </div>
            <?php if (!empty($error)): ?>
                <div class="alert alert-danger" role="alert"><?= e((string) $error) ?></div>
            <?php endif; ?>
            <form method="post" action="<?= e(url('procesar-login')) ?>">
                <input type="hidden" name="_csrf" value="<?= e($csrf ?? '') ?>">
                <div class="mb-3">
                    <label class="form-label" for="usuario">Usuario</label>
                    <input class="form-control" id="usuario" name="usuario" type="text" value="<?= e($usuario ?? '') ?>" autocomplete="username" required autofocus>
                </div>
                <div class="mb-4">
                    <label class="form-label" for="password">Contraseña</label>
                    <input class="form-control" id="password" name="password" type="password" autocomplete="current-password" required>
                </div>
                <button class="btn btn-primary w-100" type="submit">Aceptar</button>
            </form>
        </div></div>
    </div>
</div>
