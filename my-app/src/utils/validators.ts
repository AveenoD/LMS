/**
 * Form validation utilities for EdTech OS
 */

export function validateEmail(email: string): boolean {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

export function validatePhone(phone: string): boolean {
  const re = /^(\+91)?[6-9]\d{9}$/;
  return re.test(phone.replace(/\s/g, ""));
}

export function validateRequired(value: string): boolean {
  return value.trim().length > 0;
}

export interface ValidationResult {
  valid: boolean;
  message?: string;
}

export function validateBookingForm(data: {
  instituteName: string;
  name: string;
  phone: string;
  email: string;
}): ValidationResult {
  if (!validateRequired(data.instituteName)) {
    return { valid: false, message: "Institute name is required" };
  }
  if (!validateRequired(data.name)) {
    return { valid: false, message: "Your name is required" };
  }
  if (!validatePhone(data.phone)) {
    return { valid: false, message: "Please enter a valid phone number" };
  }
  if (!validateEmail(data.email)) {
    return { valid: false, message: "Please enter a valid email address" };
  }
  return { valid: true };
}
