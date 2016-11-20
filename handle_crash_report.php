<?php

// Convert a number of bytes to a human-readable string
function bytes_to_human_readable_string($bytes)
{
  $divisions = 1;
  while(1024 < $bytes) {
    $bytes /= 1024;
    ++$divisions;
  }

  $string = NULL;
  switch($divisions) {
    case 1:		$string = sprintf("%.2f bytes", $bytes); 	break;
    case 2:		$string = sprintf("%.2f KiB", $bytes); 		break;
    case 3:		$string = sprintf("%.2f MiB", $bytes); 		break;
    case 4:		$string = sprintf("%.2f GiB", $bytes); 		break;
    case 5:		$string = sprintf("%.2f TiB", $bytes); 		break;
    case 6:		$string = sprintf("%.2f PiB", $bytes); 		break;
    case 7:		$string = sprintf("%.2f EiB", $bytes); 		break;
    case 8:		$string = sprintf("%.2f ZiB", $bytes); 		break;
    case 9:		$string = sprintf("%.2f YiB", $bytes); 		break;
  }

  return $string;
}

// Convert a frequency to a human readable string
function frequency_to_human_readable_string($hertz)
{
  $divisions = 1;
  while(1000 < $hertz) {
    $hertz /= 1000;
    ++$divisions;
  }

  $string = NULL;
  switch($divisions) {
    case 1:		$string = sprintf("%.2f hertz", $hertz); 	break;
    case 2:		$string = sprintf("%.2f KHz", $hertz); 		break;
    case 3:		$string = sprintf("%.2f MHz", $hertz); 		break;
    case 4:		$string = sprintf("%.2f GHz", $hertz); 		break;
    case 5:		$string = sprintf("%.2f THz", $hertz); 		break;
    case 6:		$string = sprintf("%.2f PHz", $hertz); 		break;
    case 7:		$string = sprintf("%.2f EHZ", $hertz); 		break;
    case 8:		$string = sprintf("%.2f ZHz", $hertz); 		break;
    case 9:		$string = sprintf("%.2f YHz", $hertz); 		break;
  }

  return $string;
}

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
Version:      {$_POST['applicationShortVersion']} ({$_POST['applicationVersion']})
Date:         {$_POST['date']}
EOS;

// Add the system information, if specified
if($_POST[systemInformationIncluded]) {
  // Friendlier formats
  $CPUFrequencyString = frequency_to_human_readable_string($_POST['CPUFrequency']);
  $busFrequencyString = frequency_to_human_readable_string($_POST['busFrequency']);
  $physicalMemoryString = bytes_to_human_readable_string($_POST['physicalMemory']);

  $message_body .= <<<EOS
\n
System Information
==================
Mac OS:       {$_POST['systemVersion']} ({$_POST['systemBuildVersion']})
Machine:      {$_POST['machine']}
Model:        {$_POST['model']}
CPU Family:   {$_POST['CPUFamily']}
CPU Type:     {$_POST['CPUType']} ({$_POST['CPUSubtype']})
CPUs:         {$_POST['numberOfCPUs']} ({$_POST['physicalCPUs']} physical, {$_POST['logicalCPUs']} logical)
CPU Freq:     {$CPUFrequencyString}
Memory:       {$physicalMemoryString}
Bus Freq:     {$busFrequencyString}
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
