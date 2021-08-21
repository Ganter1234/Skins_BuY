<?PHP
	include_once("../../../inc/start.php");
	include_once("../../../inc/protect.php");
	include_once("../base/config.php");
	
	if(empty($_POST['phpactions']) || !is_admin() || $_SESSION['token'] != $_POST['token']) {
		exit(json_encode(['status' => '2']));
	}
	
	if(isset($_POST['add_skin'])) {
		if($_POST['image'] == 'undefined') exit(json_encode(['status' => '2', 'message' => 'Загрузите картинку!']));
		if(empty($_POST['name']) || strlen($_POST['name']) < 2) exit(json_encode(['status' => '2', 'message' => 'Введите название!']));
		if($_POST['price'] < 0) exit(json_encode(['status' => '2', 'message' => 'Стоимость должна быть Выше нуля!']));
		if(empty($_POST['modelt']) || strlen($_POST['modelt']) < 2) exit(json_encode(['status' => '2', 'message' => 'Внестите наименование модели t!']));
		if(empty($_POST['modelct']) || strlen($_POST['modelct']) < 2) exit(json_encode(['status' => '2', 'message' => 'Внестите название модели в ct!']));
		if(empty($_POST['server']) || $_POST['server'] <= 0) exit(json_encode(['status' => '2', 'message' => 'Укажите сервер!']));
		if(0 < $_FILES['image']['error']) exit(json_encode(['status' => '2', 'message' => $_FILES['image']['error']]));
		
		$fileName = "/modules_extra/skins_buy/uploads/" . date("siH") . rand(100, 10000) . "_{$_FILES['image']['name']}";
		
		if(move_uploaded_file($_FILES['image']['tmp_name'], "{$_SERVER['DOCUMENT_ROOT']}{$fileName}")) {
			if($pdo->query("INSERT INTO `skins_buy_users`(`server_id`, `name`, `price`, `modelt`, `modelct`, `image`) VALUES ('{$_POST['server']}', '{$_POST['name']}', '{$_POST['price']}', '{$_POST['modelt']}', '{$_POST['modelct']}', '{$fileName}')")) {
				exit(json_encode(['status' => '1', 'message' => 'Скин успешно добавлен!']));
			}
		}
		
		exit(json_encode(['status' => '2', 'message' => $_FILES['image']['error']]));
	}
	
	if(isset($_POST['del'])) {
		if($pdo->query("DELETE FROM `skins_buy_users` WHERE `id`='{$_POST['index']}'")) {
			exit(json_encode(['status' => '1', 'message' => 'Скин успешно удалён!']));
		}
		
		exit(json_encode(['status' => '2', 'message' => 'Ошибка при удаление скина..']));
	}