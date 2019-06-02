<?php

class Success {
	public $status;
	public $orderId;
}

class Failure {
	public $status;
}

// Get order in JSON format.
$order = json_decode(file_get_contents("php://input"));

// Verify that the contents are in a valid order format.
$success = true;
if (!isset($order)) $success = false;
if (!array_key_exists("customer", $order)) $success = false;
if (!array_key_exists("email", $order)) $success = false;
if (!array_key_exists("confirmReceived", $order)) $success = false;
if (!array_key_exists("confirmShipped", $order)) $success = false;
if (!array_key_exists("items", $order)) $success = false;
for ($i=0; $i<count($order->items); $i++) {
	if (!array_key_exists("name", $order->items[$i])) $success = false;
	if (!array_key_exists("quantity", $order->items[$i])) $success = false;
}
if (! $success) {
	$result = new Failure;
	$result->status = "ERROR_invalid_order_request_format";
	$response = json_encode($result);
	echo $response;
	die();
}

// Place order in SQL database.
include "../connection/connect.php";
$connection = connect();
if (isset($connection)) {
	if (! $connection->beginTransaction()) {
		$connection = null;
		$result = new Failure;
		$result->status = "ERROR_server_side";
		$response = json_encode($result);
		echo $response;
		die();
	}
	// Create customer entry.
	$query = "INSERT INTO orders (customer, email, confirmation) VALUES (\"";
	$query .= $order->customer;
	$query .= "\", \"";
	$query .= $order->email;
	$query .= "\", ";
	if ($order->confirmShipped) $query .= "true";
	else $query .= "false";
	$query .= ")";
	try {
		$connection->query($query);
	} catch (PDOexception $exception) {
		$connection = null;
		$result = new Failure;
		$result->status = "ERROR_customer_info_refused";
		$response = json_encode($result);
		echo $response;
		die();
	}
	// Get order number.
	$id = $connection->lastInsertId();
	// Insert order items.
	for ($i=0; $i<count($order->items); $i++) {
		$query = "INSERT INTO order_items (order_id, name, quantity) VALUES (";
		$query .= $id;
		$query .= ", \"";
		$query .= $order->items[$i]->name;
		$query .= "\", ";
		$query .= $order->items[$i]->quantity;
		$query .= ")";
		try {
			$connection->query($query);
		} catch (PDOexception $exception) {
			$connection = null;
			$result = new Failure;
			$result->status = "ERROR_insufficient_stock";
			$response = json_encode($result);
			echo $response;
			die();
		}
	}
	if (! $connection->commit()) {
		$connection = null;
		$result = new Failure;
		$result->status = "ERROR_server_side";
		$response = json_encode($result);
		echo $response;
		die();
	}
	$connection = null;
} else {
	$connection = null;
	$result = new Failure;
	$result->status = "ERROR_server_side";
	$response = json_encode($result);
	echo $response;
	die();
}

// Order was placed without error.
$result = new Success;
$result->status = "SUCCESS_order_placed";
$result->orderId = $id;
$response = json_encode($result);
echo $response;

if ($order->confirmReceived) {
	$to = $order->email;
	$subject = "Confirmation: Fictitious Order Received";
	$message = "Hi ".$order->customer.",\n\n";
	$message .= "This email is to confirm that your fictitious order has been received.";
	$message .= " Your order ID is ".$id.".\n\n";
	for ($i=0; $i<count($order->items); $i++) {
		$message .= $order->items[$i]->name;
		$message .= " (";
		$message .= $order->items[$i]->quantity;
		$message .= ")\n";
	}
	$message .= "\n";
	if ($order->confirmShipped) {
		$message .= "A confirmation email will be sent when your order ships. ";
	}
	$message .= "Thank you for choosing our fictitous service.";
	$message = wordwrap($message, 70);
	$additional_headers = "From: sjk.dev.test@gmail.com";
	mail($to, $subject, $message, $additional_headers);
}

?>
