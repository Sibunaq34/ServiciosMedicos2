</main>
<footer class="container pb-4 text-center text-secondary small">
    © 2026 Servicios Médicos SA ·
    <a href="<?= e(url('aviso-privacidad')) ?>">Aviso de Privacidad</a> ·
</footer>
<?php if (\App\Core\Sesion::estaAutenticado()): ?>
    </div>
</div>
<?php endif; ?>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI"
        crossorigin="anonymous"></script>
<script src="public/assets/js/app.js"></script>
<?php // Carga JS propio de cada vista. ?>
<?php foreach (($scripts ?? []) as $script): ?>
<script src="<?= e($script) ?>"></script>
<?php endforeach; ?>
</body>
</html>
