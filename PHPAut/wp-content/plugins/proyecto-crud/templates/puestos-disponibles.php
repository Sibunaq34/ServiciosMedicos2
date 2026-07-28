<?php
if (!defined('ABSPATH')) {
    exit;
}
?>

<section class="aut2-puestos-disponibles">
    <?php if (empty($aut2Puestos)): ?>
        <p class="aut2-vacio">No hay puestos disponibles en este momento.</p>
    <?php else: ?>
        <div class="aut2-grid">
            <?php foreach ($aut2Puestos as $aut2Puesto): ?>
                <a class="aut2-card" href="<?php echo esc_url($aut2Puesto['href']); ?>">
                    <span class="aut2-card-nombre"><?php echo esc_html($aut2Puesto['nombre']); ?></span>
                </a>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
</section>
