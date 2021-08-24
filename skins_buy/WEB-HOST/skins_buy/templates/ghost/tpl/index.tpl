	<div class="r_block">
		<div class="r_block_head">Магазин игровых скинов</div> 
		<div class="r_block">
				<div class="col-lg-6">
					<div class="form-group">
						<label for="skins_server" class="h6">Выберите сервер</label>
						<select id="skins_server" class="form-control" OnChange="select_server();">{servers}</select>
					</div>
					<div class="form-group" id="skins_list"></div>
					
					<button id="buy" class="btn btn-primary btn-block" OnClick="buy();" disabled>Купить</button>
					
					<div id="result_buy"></div>
				</div>
				
				<div class="col-lg-6">
					<div class="form-group">
						<label class="h6">Информация о товаре</label>
						<div class="with_code noty-block" id="skins_info"></div>
					</div>
				</div>
		</div>
	</div>
</div>
<div class="left_block">
	{include file="/home/right_col.tpl"}
</div>
<script src="../../../modules_extra/skins_store/ajax/main.js?v={cache}"></script>