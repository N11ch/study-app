import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  // POST http://localhost:3000/auth/signup
  @Post('signup')
  async signUp(@Body() body: any) {
    return this.authService.signUp(body.email, body.password, body.role);
  }

  // POST http://localhost:3000/auth/login
  @Post('login')
  async login(@Body() body: any) {
    return this.authService.login(body.email, body.password);
  }
}
