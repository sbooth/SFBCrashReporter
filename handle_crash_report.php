<?php

// If this isn't a crash report redirect to the server's main page
if($_SERVER['HTTP_USER_AGENT'] != 'SFBCrashReporter') {
    header('Location: http://' . $_SERVER['SERVER_NAME']);
    return;
}

// Use SwiftMailer to do the actual work
// Get the source from http://swiftmailer.org/
require_once '/path/to/swift-mailer/lib/swift_required.php';

// Use the gmail servers
$transport = Swift_SmtpTransport::newInstance('smtp.gmail.com', 465, 'tls');
$transport->setUsername('you@gmail.com');
$transport->setPassword('your_password');

$mailer = Swift_Mailer::newInstance($transport);

// Build the message
$message = Swift_Message::newInstance();

// Send the message to yourself
$message->setFrom('you@gmail.com');
$message->setTo('you@gmail.com');

$message->setSubject($_POST['applicationName'] . ' crash report');

// Construct the message body
$message_body = <<<EOS
Application Information
=======================
Application:  {$_POST['applicationName']} ({$_POST['applicationIdentifier']})
Version:      {$_POST['applicationVersion']} ({$_POST['applicationShortVersion']})
Date:         {$_POST['date']}
EOS;

// Add the system information, if specified
if($_POST[systemInformationIncluded]) {
  $message_body .= <<<EOS
\n
System Information
==================
Mac OS:       {$_POST['systemVersion']} ({$_POST['systemBuildVersion']})
Machine:      {$_POST['machine']}
Model:        {$_POST['modelName']}
CPU Family:   {$_POST['CPUFamilyName']}
CPUs:         {$_POST['numberOfCPUs']}
CPU Freq:     {$_POST['CPUFrequency']}
Memory:       {$_POST['physicalMemory']}
Bus Freq:     {$_POST['busFrequency']}
EOS;
}

// Append comments, if any were submitted
if(strlen($_POST['comments'])) {
  $message_body .= <<<EOS
\n
Additional Comments
===================
{$_POST['comments']}
EOS;
}

// Append e-mail address if provided
if(strlen($_POST['emailAddress'])) {
  $message_body .= <<<EOS
\n
Submitted by: {$_POST['emailAddress']}
EOS;
}

$message->addPart($message_body, 'text/plain');

// Attach the crash log
if($_FILES['crashLog']['size']) {
	$attachment = Swift_Attachment::fromPath($_FILES['crashLog']['tmp_name'], $_FILES['crashLog']['type']);
	$attachment->setFilename($_FILES['crashLog']['name']);
	$message->attach($attachment);
}

// Send the message
$result = $mailer->send($message);

if(0 == $result)
    echo 'err';
else
    echo 'ok';

?>
