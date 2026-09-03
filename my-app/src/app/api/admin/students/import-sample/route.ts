import { NextRequest, NextResponse } from 'next/server';
import * as XLSX from 'xlsx';
import { requireAuth } from '@/lib/middleware/auth';
import { handleApiError } from '@/lib/utils/apiResponse';

const COLUMNS = ['Full Name', 'Phone', 'Password', 'Parent Name', 'Parent Phone', 'Grade', 'Roll No', 'Batch Name'];

const SAMPLE_ROWS = [
  {
    'Full Name': 'Aarav Joshi',
    Phone: '9000000021',
    Password: 'student123',
    'Parent Name': 'Rakesh Joshi',
    'Parent Phone': '9000000022',
    Grade: 'Class 11',
    'Roll No': 'A-102',
    'Batch Name': 'JEE 2026 Morning',
  },
  {
    'Full Name': 'Diya Mehta',
    Phone: '9000000023',
    Password: 'student123',
    'Parent Name': 'Suresh Mehta',
    'Parent Phone': '9000000024',
    Grade: 'Class 12',
    'Roll No': '',
    'Batch Name': 'NEET 26',
  },
];

// New: downloadable .xlsx template for POST /admin/students/import.
// "Batch Name" must exactly match an existing batch's name in this institute.
export async function GET(req: NextRequest) {
  try {
    requireAuth(req, 'coaching_admin');

    const sheet = XLSX.utils.json_to_sheet(SAMPLE_ROWS, { header: COLUMNS });
    sheet['!cols'] = COLUMNS.map((c) => ({ wch: Math.max(c.length + 2, 16) }));
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, sheet, 'Students');
    const buffer = XLSX.write(workbook, { type: 'buffer', bookType: 'xlsx' }) as Buffer;

    return new NextResponse(new Uint8Array(buffer), {
      status: 200,
      headers: {
        'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'Content-Disposition': 'attachment; filename="student-import-sample.xlsx"',
      },
    });
  } catch (err) {
    return handleApiError(err);
  }
}
